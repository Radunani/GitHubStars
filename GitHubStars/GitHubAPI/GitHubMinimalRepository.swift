public struct GitHubMinimalRepository: Sendable, Codable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let description: String?
    public var stargazersCount: Int
}
