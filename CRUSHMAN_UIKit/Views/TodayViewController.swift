import UIKit
import SwiftData

/// 이모지 그리드 + 한 줄 메모. 이모지 탭 = 즉시 저장, 하루 1건.
///
/// 자정 버그 대응:
/// - `today`를 프로퍼티로 들고, 조회 predicate를 매번 `today`로 새로 만든다.
/// - 앱을 켜 둔 채 자정을 넘긴 경우: `.NSCalendarDayChanged`
/// - 백그라운드에 있다가 다음 날 다시 연 경우: `didBecomeActiveNotification`
///   (이땐 dayChanged가 안 올 수 있어 둘 다 관찰한다.)
final class TodayViewController: UIViewController {

    private let context: ModelContext
    private var today = Calendar.current.startOfDay(for: .now)
    private var entry: MoodEntry?

    private let moods = Mood.allCases

    // MARK: UI

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseID)
        return cv
    }()

    private let noteField: UITextField = {
        let field = UITextField()
        field.placeholder = "한 줄 메모 (선택)"
        field.borderStyle = .none
        field.backgroundColor = .quaternarySystemFill
        field.layer.cornerRadius = 12
        field.returnKeyType = .done
        // 좌우 여백
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.rightViewMode = .always
        return field
    }()

    // MARK: Init

    init(context: ModelContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CRUSHMAN"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        setupLayout()
        setupNoteField()
        observeDayChanges()

        loadEntry()
        updateUI()
    }

    // MARK: Setup

    private func setupLayout() {
        let header = UIStackView(arrangedSubviews: [dateLabel, statusLabel])
        header.axis = .vertical
        header.spacing = 4

        let root = UIStackView(arrangedSubviews: [header, collectionView, noteField])
        root.axis = .vertical
        root.spacing = 28
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // 이모지 그리드: 2줄 × 4열, 각 셀 높이 90 기준
            collectionView.heightAnchor.constraint(equalToConstant: 180),
            noteField.heightAnchor.constraint(equalToConstant: 52),
        ])

        // 빈 곳 탭 → 키보드 내림
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupNoteField() {
        noteField.delegate = self
        noteField.addTarget(self, action: #selector(noteEditingEnded), for: .editingDidEnd)
    }

    private func observeDayChanges() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshDay),
            name: .NSCalendarDayChanged, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshDay),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }

    // MARK: Data

    private func loadEntry() {
        let day = today
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.day == day }
        )
        entry = try? context.fetch(descriptor).first
    }

    /// 이모지 탭 = 즉시 저장. 같은 날 다시 탭하면 덮어쓴다.
    private func select(_ mood: Mood) {
        Haptics.select()

        if let entry {
            guard entry.emoji != mood.emoji else { return }
            entry.emoji = mood.emoji
            entry.updatedAt = .now
        } else {
            let new = MoodEntry(emoji: mood.emoji, note: noteField.text ?? "", day: today)
            context.insert(new)
            entry = new
        }

        try? context.save()
        Haptics.saved()
        updateUI()
    }

    private func saveNote() {
        guard let entry, entry.note != (noteField.text ?? "") else { return }
        entry.note = noteField.text ?? ""
        entry.updatedAt = .now
        try? context.save()
    }

    // MARK: Day refresh (자정 버그 대응)

    @objc private func refreshDay() {
        let now = Calendar.current.startOfDay(for: .now)
        guard now != today else { return }
        today = now
        loadEntry()
        updateUI()
    }

    // MARK: UI update

    private func updateUI() {
        dateLabel.text = today.formatted(.dateTime.month(.wide).day().weekday(.wide))
        statusLabel.text = (entry == nil) ? "오늘 기분은 어때요?" : "오늘 기록됨"

        let hasEntry = entry != nil
        noteField.isEnabled = hasEntry
        noteField.alpha = hasEntry ? 1 : 0.4
        if !noteField.isFirstResponder {
            noteField.text = entry?.note ?? ""
        }

        collectionView.reloadData()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func noteEditingEnded() {
        saveNote()
    }

    // MARK: Layout factory

    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionView

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        moods.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.reuseID, for: indexPath
        ) as! EmojiCell
        let mood = moods[indexPath.item]
        cell.configure(mood: mood, isSelected: entry?.emoji == mood.emoji)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(moods[indexPath.item])
    }
}

// MARK: - UITextFieldDelegate

extension TodayViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
