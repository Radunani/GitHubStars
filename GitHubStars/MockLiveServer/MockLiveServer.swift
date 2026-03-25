import Combine
import Foundation

public actor MockLiveServer {
    public typealias Subscriber = @Sendable (_ newStars: Int) -> Void

    private var subscribers: [Int: [UUID: Subscriber]] = [:]
    private var subscribedRepos: [Int: Task<Void, Never>] = [:]

    public init() {}

    public func subscribeToRepo(
        repoId: Int,
        currentStars: Int,
        subscriber: @escaping Subscriber
    ) -> AnyCancellable {
        let subscriptionUUID = UUID()
        subscribers[repoId, default: [:]][subscriptionUUID] = subscriber

        if subscribers[repoId, default: [:]].count == 1 {
            startSendingUpdates(repoId: repoId, currentStars: currentStars)
        }

        return AnyCancellable { @Sendable [weak self] in
            Task {
                await self?.removeSubscription(repoId: repoId, subscriptionUUID: subscriptionUUID)
            }
        }
    }

    private func removeSubscription(repoId: Int, subscriptionUUID: UUID) {
        subscribers[repoId]?.removeValue(forKey: subscriptionUUID)
        if self.subscribers[repoId, default: [:]].isEmpty {
            subscribedRepos[repoId]?.cancel()
            subscribedRepos[repoId] = nil
        }
    }

    private func startSendingUpdates(repoId: Int, currentStars: Int) {
        subscribedRepos[repoId]?.cancel()
        subscribedRepos[repoId] = Task { [weak self] in
            var starsCount = currentStars

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .milliseconds(.random(in: 100...1000)))
                } catch {
                    break
                }

                guard let self else { break }

                starsCount += .random(in: 1...3)

                for subscriber in await self.subscribers[repoId, default: [:]].values {
                    subscriber(starsCount)
                }
            }
        }
    }
}
