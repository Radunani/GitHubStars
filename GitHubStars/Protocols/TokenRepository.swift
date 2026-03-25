protocol TokenRepository {
    var hasToken: Bool { get }
    func saveToken(_ token: String) throws
    func getToken() throws -> String?
    func deleteToken() throws
}
