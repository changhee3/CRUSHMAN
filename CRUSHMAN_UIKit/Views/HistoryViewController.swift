import UIKit
import SwiftData

/// 날짜 역순 리스트 + 스와이프 삭제. SwiftUI의 `HistoryView` 대응.
final class HistoryViewController: UITableViewController {

    private let context: ModelContext
    private var entries: [MoodEntry] = []

    init(context: ModelContext) {
        self.context = context
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "기록"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    /// 오늘 탭에서 기록이 추가/변경될 수 있으므로 나타날 때마다 다시 읽는다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func reload() {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )
        entries = (try? context.fetch(descriptor)) ?? []
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if entries.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "face.smiling")
            config.text = "아직 기록이 없어요"
            config.secondaryText = "오늘 탭에서 이모지를 눌러 시작하세요."
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }

    // MARK: Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = entries[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.image = emojiImage(entry.emoji)
        config.text = entry.day.formatted(.dateTime.year().month().day())
        config.textProperties.font = .preferredFont(forTextStyle: .subheadline)
        if !entry.note.isEmpty {
            config.secondaryText = entry.note
            config.secondaryTextProperties.color = .secondaryLabel
        }
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let entry = entries.remove(at: indexPath.row)
        context.delete(entry)
        try? context.save()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        updateEmptyState()
    }

    /// 이모지 문자열을 셀 leading 이미지로 쓰기 위해 렌더링한다.
    private func emojiImage(_ emoji: String) -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let attr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 32)]
            let str = emoji as NSString
            let textSize = str.size(withAttributes: attr)
            let origin = CGPoint(x: (size.width - textSize.width) / 2,
                                 y: (size.height - textSize.height) / 2)
            str.draw(at: origin, withAttributes: attr)
        }
    }
}
