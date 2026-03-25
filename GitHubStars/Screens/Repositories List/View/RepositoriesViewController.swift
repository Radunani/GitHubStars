import UIKit

@MainActor
protocol RepositoriesView: UIViewController {
    func displayRepositories(_ repositories: [GitHubMinimalRepository])
    func updateStarCount(for repoId: Int, newCount: Int)
    func showError(_ error: Error)
    func showLoading()
    func hideLoading()
}

@MainActor
final class RepositoriesViewController: UITableViewController, RepositoriesView {
    var presenter: RepositoriesPresenter!

    private var repositories: [GitHubMinimalRepository] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRefreshControl()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            presenter.viewWillDisappear()
        }
    }

    private func setupTableView() {
        tableView.register(
            RepositoryTableViewCell.self,
            forCellReuseIdentifier: RepositoryTableViewCell.identifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshData() {
        presenter.refreshData()
    }

    func displayRepositories(_ repositories: [GitHubMinimalRepository]) {
        self.repositories = repositories
        tableView.reloadData()
        hideLoading()
    }

    func updateStarCount(for repoId: Int, newCount: Int) {
        guard let index = repositories.firstIndex(where: { $0.id == repoId }) else { return }

        repositories[index].stargazersCount = newCount

        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RepositoryTableViewCell {
            cell.setStarCount(count: newCount.formatted())
        }
    }

    func showError(_ error: Error) {
        tableView.refreshControl?.endRefreshing()
        presenter.showError(error)
    }

    func showLoading() {
        tableView.refreshControl?.beginRefreshing()
    }

    func hideLoading() {
        tableView.refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RepositoryTableViewCell.identifier,
            for: indexPath
        ) as! RepositoryTableViewCell

        cell.configure(with: repositories[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRepository(repositories[indexPath.row])
    }
}
