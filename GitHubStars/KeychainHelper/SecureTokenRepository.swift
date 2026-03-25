import Foundation

final class SecureTokenRepository: TokenRepository {
    private let keychain: KeychainClient
    private let service: String
    private let account: String

    init(
        keychain: KeychainClient,
        service: String,
        account: String
    ) {
        self.keychain = keychain
        self.service = service
        self.account = account
    }

    func saveToken(_ token: String) throws {
        let data = Data(token.utf8)
        try keychain.save(data: data, service: service, account: account)
    }

    func getToken() throws -> String? {
        guard let data = try keychain.load(
            service: service,
            account: account
        ) else { return nil }

        return String(decoding: data, as: UTF8.self)
    }

    func deleteToken() throws {
        try keychain.delete(service: service, account: account)
    }

    var hasToken: Bool {
        (try? getToken()) != nil
    }
}
