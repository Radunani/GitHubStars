import UIKit

@MainActor
protocol RepositoriesBuilder {
    func buildRepositoriesViewController(
        organisation: String,
        gitHubAPI: GitHubAPI
    ) -> UIViewController
}

final class RepositoriesDefaultBuilder: NSObject, RepositoriesBuilder {
    func buildRepositoriesViewController(
        organisation: String,
        gitHubAPI: GitHubAPI
    ) -> UIViewController {
        let interactor = RepositoriesInteractorImp(
            gitHubAPI: gitHubAPI,
            organisation: organisation,
            mockLiveServer: MockLiveServer()
        )

        let viewController = RepositoriesViewController(style: .insetGrouped)

        let router = RepositoriesRouterImp()
        router.viewController = viewController

        let presenter = RepositoriesPresenterImp(
            view: viewController,
            interactor: interactor,
            router: router
        )

        viewController.presenter = presenter

        viewController.title = organisation

        return viewController
    }
}
