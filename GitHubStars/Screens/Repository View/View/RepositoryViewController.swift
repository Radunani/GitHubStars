import SwiftUI
import UIKit

@MainActor
final class RepositoryViewController: UIViewController {
    private let minimalRepository: GitHubMinimalRepository
    private let gitHubAPI: GitHubAPI

    private let starsPublisher: StarsPublisher

    init(
        minimalRepository: GitHubMinimalRepository,
        gitHubAPI: GitHubAPI,
        starsPublisher: StarsPublisher
    ) {
        self.minimalRepository = minimalRepository
        self.gitHubAPI = gitHubAPI
        self.starsPublisher = starsPublisher
        super.init(nibName: nil, bundle: nil)

        title = minimalRepository.name
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingViewController = UIHostingController(
            rootView: RepositoryView(
                minimalRepository: minimalRepository,
                gitHubAPI: gitHubAPI,
                starsPublisher: starsPublisher
            )
        )

        addChild(hostingViewController)
        view.addSubview(hostingViewController.view)
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        hostingViewController.didMove(toParent: self)
    }
}

private struct RepositoryView: View {
    let minimalRepository: GitHubMinimalRepository
    let gitHubAPI: GitHubAPI

    @StateObject private var starsViewModel: RepositoryStarsViewModel

    @State private var fullRepository: GitHubFullRepository?

    init(
        minimalRepository: GitHubMinimalRepository,
        gitHubAPI: GitHubAPI,
        starsPublisher: StarsPublisher
    ) {
        self.minimalRepository = minimalRepository
        self.gitHubAPI = gitHubAPI

        _starsViewModel = StateObject(
            wrappedValue: RepositoryStarsViewModel(
                initialStars: minimalRepository.stargazersCount,
                starsPublisher: starsPublisher
            )
        )
    }

    var body: some View {
        List {
            RepositoryValueView(key: "Name") {
                Text(minimalRepository.name)
                    .foregroundColor(.secondary)
            }

            RepositoryValueView(key: "Description") {
                if let description = minimalRepository.description {
                    Text(description)
                        .foregroundColor(.secondary)
                } else {
                    Text("No description")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            RepositoryValueView(key: "Stars") {
                Text("\(starsViewModel.stars)")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            RepositoryValueView(key: "Forks") {
                if let fullRepository {
                    Text("\(fullRepository.networkCount)")
                        .foregroundColor(.secondary)
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            do {
                let repository = try await gitHubAPI.repository(minimalRepository.fullName)
                guard !Task.isCancelled else { return }
                fullRepository = repository
            } catch {
                print("Error loading full repository: \(error)")
            }
        }
    }
}

private struct RepositoryValueView<Value: View>: View {
    let key: String
    let value: Value

    var body: some View {
        VStack(alignment: .leading) {
            Text(key)
                .font(.headline)
            value
        }
    }

    init(key: String, @ViewBuilder value: () -> Value) {
        self.key = key
        self.value = value()
    }
}
