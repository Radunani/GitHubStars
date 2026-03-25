import Combine

@MainActor
protocol RepositoriesInteractor {
    var githubAPI: GitHubAPI { get }

    func fetchRepositories() async throws -> [GitHubMinimalRepository]

    func subscribeToRepoStars(
        repoId: Int,
        currentStars: Int,
        update: @escaping @MainActor (Int) -> Void
    ) async

    func cancelAllSubscriptions()
}

@MainActor
final class RepositoriesInteractorImp: RepositoriesInteractor {
    private let gitHubAPI: GitHubAPI
    private let organisation: String
    private let mockLiveServer: MockLiveServer

    private var cancellables = Set<AnyCancellable>()
    private var subscriptionGeneration = 0

    init(gitHubAPI: GitHubAPI, organisation: String, mockLiveServer: MockLiveServer) {
        self.gitHubAPI = gitHubAPI
        self.organisation = organisation
        self.mockLiveServer = mockLiveServer
    }

    var githubAPI: GitHubAPI { gitHubAPI }

    func fetchRepositories() async throws -> [GitHubMinimalRepository] {
        let repositories = try await gitHubAPI.repositoriesForOrganisation(organisation)

        return repositories.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    func subscribeToRepoStars(
        repoId: Int,
        currentStars: Int,
        update: @escaping @MainActor (Int) -> Void
    ) async {
        let generation = subscriptionGeneration
        let cancellable = await mockLiveServer.subscribeToRepo(
            repoId: repoId,
            currentStars: currentStars
        ) { [weak self] newStars in
            Task { @MainActor [weak self] in
                guard let self, self.subscriptionGeneration == generation else { return }
                update(newStars)
            }
        }

        guard generation == subscriptionGeneration else {
            cancellable.cancel()
            return
        }

        cancellables.insert(cancellable)
    }

    func cancelAllSubscriptions() {
        subscriptionGeneration += 1
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
