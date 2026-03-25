import Foundation

protocol KeychainClient {
    func save(data: Data, service: String, account: String) throws
    func load(service: String, account: String) throws -> Data?
    func delete(service: String, account: String) throws
}
