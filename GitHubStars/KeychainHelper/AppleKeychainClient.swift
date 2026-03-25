import Security
import Foundation

final class AppleKeychainClient: KeychainClient {
    func save(data: Data, service: String, account: String) throws {
        try delete(service: service, account: account)
        var query = baseQueryParams(service: service, account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func load(service: String, account: String) throws -> Data? {
        var query = baseQueryParams(service: service, account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            return item as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func delete(service: String, account: String) throws {
        let query = baseQueryParams(service: service, account: account)
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func baseQueryParams(service: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

extension AppleKeychainClient {
    enum KeychainError: PresentableError {
        case unexpectedStatus(OSStatus)

        var alertTitle: String {
            "Secure Storage Error"
        }

        var alertMessage: String {
            switch self {
            case .unexpectedStatus:
                return "Unable to securely access stored credentials. Please try again."
            }
        }
    }
}
