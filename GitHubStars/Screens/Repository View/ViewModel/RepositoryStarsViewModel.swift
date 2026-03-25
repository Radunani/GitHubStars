import Combine

@MainActor
final class RepositoryStarsViewModel: ObservableObject {
    @Published private(set) var stars: Int

    private var observationTask: Task<Void, Never>?

    init(initialStars: Int, starsPublisher: StarsPublisher) {
        self.stars = initialStars

        observationTask = Task { [weak self] in
            guard let self else { return }

            for await newStars in starsPublisher.values {
                guard !Task.isCancelled else { break }
                self.stars = newStars
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
