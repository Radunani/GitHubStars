import UIKit
import Combine

@MainActor
final class TokenInputViewController: UIViewController {
    private let tokenTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter GitHub Personal Access Token"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Token", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.isEnabled = false
        return button
    }()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Token", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private let tokenStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    private let goToRepositories: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Repositories", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let viewModel: TokenInputViewModel

    private let repositoriesBuilder: RepositoriesBuilder

    private var cancelables = Set<AnyCancellable>()

    init(viewModel: TokenInputViewModel, repositoriesBuilder: RepositoriesBuilder) {
        self.viewModel = viewModel
        self.repositoriesBuilder = repositoriesBuilder
        super.init(nibName: nil, bundle: nil)
        title = "GitHub Token"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [
            tokenTextField,
            saveButton,
            clearButton,
            tokenStatusLabel,
            infoLabel,
            goToRepositories
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveToken), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(deleteToken), for: .touchUpInside)
        goToRepositories.addTarget(self, action: #selector(navigateToRepositories), for: .touchUpInside)
        tokenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tokenTextField.delegate = self
    }

    private func bindViewModel() {
        viewModel.$state
            .sink { [weak self] value in
                switch value {
                case .saved: self?.applySavedTokenUI()
                case .empty: self?.applyNoTokenUI()
                }
            }
            .store(in: &cancelables)

        viewModel.$alert
            .compactMap { $0 }
            .sink { [weak self] alert in
                self?.showAlert(title: alert.title, message: alert.message)
            }
            .store(in: &cancelables)

        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorAlert(error: error)
            }
            .store(in: &cancelables)
    }

    @objc private func saveToken() {
        viewModel.saveToken(tokenTextField.text)
    }

    @objc private func deleteToken() {
        viewModel.deleteToken()
    }

    @objc private func textFieldDidChange() {
        saveButton.isEnabled = !(tokenTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    @objc private func navigateToRepositories() {
        view.endEditing(true)

            do {
                let api = try viewModel.makeAPIForSavedToken()

                let vc = repositoriesBuilder.buildRepositoriesViewController(
                    organisation: "swiftlang",
                    gitHubAPI: api
                )

                navigationController?.pushViewController(vc, animated: true)
            } catch {
                showErrorAlert(error: error)
            }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func applySavedTokenUI() {
        tokenTextField.apply(text: "••••••••••••••••", isEnabled: false, backgroundColor: .systemGray6)
        tokenStatusLabel.apply(text: "✅ Token is saved", color: .systemGreen)
        clearButton.isHidden = false
        saveButton.isHidden = true
        infoLabel.text = Constants.infoWithToken
    }

    private func applyNoTokenUI() {
        tokenTextField.apply(text: "", isEnabled: true, backgroundColor: .systemBackground, placeholder: "Enter GitHub Personal Access Token")
        tokenStatusLabel.apply(text: "⚠️ No token saved (rate limit: 60 requests/hour)", color: .systemOrange)
        clearButton.isHidden = true
        saveButton.isHidden = false
        saveButton.isEnabled = false
        infoLabel.text = Constants.infoNoToken
    }

    private enum Constants {
        static let infoNoToken = """
        • Get token from: GitHub → Settings → Developer settings → Personal access tokens
        • Required scopes: using GitHubAPI (5000 requests/hour)
        """

        static let infoWithToken = """
        • Token is saved (5000 requests/hour)
        • Clear token to enter a new one
        • Token is stored securely in Keychain
        """
    }
}

extension TokenInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if saveButton.isEnabled { viewModel.saveToken(textField.text) }
        return true
    }
}

private extension UITextField {
    func apply(text: String, isEnabled: Bool, backgroundColor: UIColor, placeholder: String? = nil) {
        self.text = text
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.placeholder = placeholder
    }
}

private extension UILabel {
    func apply(text: String, color: UIColor) {
        self.text = text
        self.textColor = color
    }
}
