public struct GitHubFullRepository: Sendable, Codable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let description: String?
    public let stargazersCount: Int
    public let networkCount: Int
}
