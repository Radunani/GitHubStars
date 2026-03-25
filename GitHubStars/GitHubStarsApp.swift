import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let tokenRepository: TokenRepository
    private let repositoriesBuilder: RepositoriesDefaultBuilder
    private let appleKeychainClient: AppleKeychainClient

    init(window: UIWindow) {
        self.window = window
        self.repositoriesBuilder = RepositoriesDefaultBuilder()
        self.appleKeychainClient = AppleKeychainClient()
        self.tokenRepository = SecureTokenRepository(
            keychain: appleKeychainClient,
            service: Bundle.main.bundleIdentifier ?? "com.github.client",
            account: "github_personal_access_token"
        )
    }

    func start() {
        let viewModel = TokenInputViewModel(
            tokenRepository: tokenRepository,
            makeGitHubAPI: { token in
                GitHubAPI(authorisationToken: token)
            }
        )

        let tokenVC = TokenInputViewController(viewModel: viewModel, repositoriesBuilder: repositoriesBuilder)

        window.rootViewController = UINavigationController(rootViewController: tokenVC)
        window.makeKeyAndVisible()
    }
}
