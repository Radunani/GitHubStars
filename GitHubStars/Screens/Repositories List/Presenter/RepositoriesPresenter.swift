import Combine

@MainActor
protocol RepositoriesPresenter {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func didSelectRepository(_ repository: GitHubMinimalRepository)
    func refreshData()
    func showError(_ error: Error)
}

@MainActor
final class RepositoriesPresenterImp: RepositoriesPresenter {
    private var starsSubjects: [Int: CurrentValueSubject<Int, Never>] = [:]
    private var fetchTask: Task<Void, Never>?
    private var resubscribeTask: Task<Void, Never>?
    private var fetchGeneration = 0

    private let view: RepositoriesView
    private let interactor: RepositoriesInteractor
    private let router: RepositoriesRouter

    private var selectedRepoId: Int?

    private var viewRepositories: [GitHubMinimalRepository] = []

    init(
        view: RepositoriesView,
        interactor: RepositoriesInteractor,
        router: RepositoriesRouter
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    deinit {
        fetchTask?.cancel()
        resubscribeTask?.cancel()
    }

    func viewDidLoad() {
        fetchRepositories(showLoading: false)
    }

    func viewWillAppear() {
        guard selectedRepoId != nil else { return }
        selectedRepoId = nil

        resubscribeToVisibleRepositories()
    }

    func viewWillDisappear() {
        fetchTask?.cancel()
        resubscribeTask?.cancel()
        interactor.cancelAllSubscriptions()
        removeAllStarsPublishers()
    }

    func refreshData() {
        fetchTask?.cancel()
        resubscribeTask?.cancel()
        interactor.cancelAllSubscriptions()
        fetchRepositories(showLoading: true)
    }

    func didSelectRepository(_ repository: GitHubMinimalRepository) {
        selectedRepoId = repository.id

        resubscribeTask?.cancel()
        interactor.cancelAllSubscriptions()

        resubscribeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            await self.subscribeToStars(for: repository)
        }

        let publisher = starsPublisher(
            for: repository.id,
            initial: repository.stargazersCount
        )

        router.navigateToRepositoryDetail(
            repository,
            gitHubAPI: interactor.githubAPI,
            starsPublisher: publisher
        )
    }

    private func fetchRepositories(showLoading: Bool) {
        if showLoading { view.showLoading() }

        fetchGeneration += 1
        let generation = fetchGeneration

        fetchTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let repositories = try await self.interactor.fetchRepositories()
                try Task.checkCancellation()
                guard generation == self.fetchGeneration else { return }

                self.viewRepositories = repositories
                self.pruneStarsPublishers(keeping: Set(repositories.map(\.id)))
                self.view.displayRepositories(repositories)
                self.resubscribeToVisibleRepositories()
                self.fetchTask = nil
            } catch is CancellationError {
                guard generation == self.fetchGeneration else { return }
                if showLoading { self.view.hideLoading() }
                self.fetchTask = nil
            } catch {
                guard generation == self.fetchGeneration else { return }
                if showLoading { self.view.hideLoading() }
                self.view.showError(error)
                self.fetchTask = nil
            }
        }
    }

    private func resubscribeToVisibleRepositories() {
        resubscribeTask?.cancel()
        interactor.cancelAllSubscriptions()

        let repositories = viewRepositories
        resubscribeTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for repository in repositories {
                guard !Task.isCancelled else { return }
                await self.subscribeToStars(for: repository)
            }
        }
    }

    private func subscribeToStars(for repository: GitHubMinimalRepository) async {
        _ = starsPublisher(for: repository.id, initial: repository.stargazersCount)

        await interactor.subscribeToRepoStars(
            repoId: repository.id,
            currentStars: repository.stargazersCount
        ) { [weak self] newStars in
            guard let self else { return }

            if let index = self.viewRepositories.firstIndex(where: { $0.id == repository.id }) {
                self.viewRepositories[index].stargazersCount = newStars
                self.view.updateStarCount(for: repository.id, newCount: newStars)
            }

            self.sendStars(newStars, for: repository.id)
        }
    }

    private func starsSubject(
        for repoId: Int,
        initial: Int
    ) -> CurrentValueSubject<Int, Never> {
        if let subject = starsSubjects[repoId] {
            return subject
        }

        let subject = CurrentValueSubject<Int, Never>(initial)
        starsSubjects[repoId] = subject
        return subject
    }

    private func starsPublisher(for repoId: Int, initial: Int) -> StarsPublisher {
        starsSubject(for: repoId, initial: initial)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func sendStars(_ stars: Int, for repoId: Int) {
        starsSubject(for: repoId, initial: stars)
            .send(stars)
    }

    private func pruneStarsPublishers(keeping repoIds: Set<Int>) {
        starsSubjects = starsSubjects.filter { repoIds.contains($0.key) }
    }

    private func removeAllStarsPublishers() {
        starsSubjects.removeAll()
    }

    func showError(_ error: Error) {
        router.showErrorAlert(error)
    }
}
