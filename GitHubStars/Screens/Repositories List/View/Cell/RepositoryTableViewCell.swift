import UIKit

final class RepositoryTableViewCell: UITableViewCell {
    static let identifier: String = "RepositoryCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold)
        label.font = boldDescriptor.flatMap { UIFont(descriptor: $0, size: 0) } ?? baseFont

        label.numberOfLines = 0

        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let starImageView: UIImageView = {
        let imageView = UIImageView()

        let configuration = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .caption1)
        )
        imageView.image = UIImage(
            systemName: "star.fill",
            withConfiguration: configuration
        )

        imageView.tintColor = .systemYellow
        return imageView
    }()

    private let starCountLabel: UILabel = {
        let label = UILabel()

        label.font = .monospacedSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize,
            weight: .regular
        )

        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            starImageView,
            starCountLabel
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .firstBaseline
        return stack
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleStackView,
            descriptionLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor
            )
        ])

        starImageView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        starCountLabel.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        nameLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
    }

    func configure(with viewModel: GitHubMinimalRepository) {
        nameLabel.text = viewModel.name
        starCountLabel.text = viewModel.stargazersCount.formatted()
        descriptionLabel.text = viewModel.description
    }

    func setStarCount(count: String) {
        starCountLabel.text = count
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
