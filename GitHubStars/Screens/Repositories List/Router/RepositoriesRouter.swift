import UIKit

@MainActor
protocol RepositoriesRouter {
    func navigateToRepositoryDetail(
        _ repository: GitHubMinimalRepository,
        gitHubAPI: GitHubAPI,
        starsPublisher: StarsPublisher
    )

    func showErrorAlert(_ error: Error)
}

@MainActor
final class RepositoriesRouterImp: RepositoriesRouter {
    weak var viewController: UIViewController?

    func navigateToRepositoryDetail(
        _ repository: GitHubMinimalRepository,
        gitHubAPI: GitHubAPI,
        starsPublisher: StarsPublisher
    ) {
        let repositoryViewController = RepositoryViewController(
            minimalRepository: repository,
            gitHubAPI: gitHubAPI,
            starsPublisher: starsPublisher
        )

        viewController?
            .navigationController?
            .pushViewController(repositoryViewController, animated: true)
    }

    func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        viewController?.present(alert, animated: true)
    }
}
