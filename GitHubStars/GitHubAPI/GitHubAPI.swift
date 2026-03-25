import Foundation

public struct GitHubAPI: Sendable {
    private let baseURL: URL
    private let authorisationToken: String?
    private let urlSession: URLSession

    public init(
        baseURL: URL = URL(string: "https://api.github.com")!,
        authorisationToken: String? = nil,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.authorisationToken = authorisationToken
        self.urlSession = urlSession
    }

    public func repositoriesForOrganisation(_ organisation: String) async throws -> [GitHubMinimalRepository] {
        let url = baseURL.appendingPathComponent("orgs/\(organisation)/repos")
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let authorisationToken {
            request.setValue("Bearer \(authorisationToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await urlSession.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([GitHubMinimalRepository].self, from: data)
    }

    public func repository(_ fullName: String) async throws -> GitHubFullRepository {
        let url = baseURL.appendingPathComponent("repos/\(fullName)")
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let authorisationToken {
            request.setValue("Bearer \(authorisationToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await urlSession.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubFullRepository.self, from: data)
    }
}
