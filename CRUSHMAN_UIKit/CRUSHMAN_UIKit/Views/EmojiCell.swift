import UIKit

/// 이모지 + 라벨을 보여주는 컬렉션 셀.
/// 선택 시 배경 강조 + 살짝 확대(SwiftUI의 scaleEffect 애니메이션 대응).
final class EmojiCell: UICollectionViewCell {
    static let reuseID = "EmojiCell"

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textAlignment = .center
        return label
    }()

    private let container = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        let stack = UIStackView(arrangedSubviews: [emojiLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }

    func configure(mood: Mood, isSelected: Bool) {
        emojiLabel.text = mood.emoji
        titleLabel.text = mood.label
        titleLabel.textColor = isSelected ? .tintColor : .secondaryLabel
        container.backgroundColor = isSelected
            ? UIColor.tintColor.withAlphaComponent(0.15)
            : .clear

        // 선택 시 확대 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.emojiLabel.transform = isSelected
                ? CGAffineTransform(scaleX: 1.15, y: 1.15)
                : .identity
        }

        // 접근성
        isAccessibilityElement = true
        accessibilityLabel = mood.label
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.transform = .identity
    }
}
