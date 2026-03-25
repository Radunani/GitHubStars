import Foundation

enum TokenState {
    case empty
    case saved
}

struct AlertItem {
    let title: String
    let message: String
}

@MainActor
final class TokenInputViewModel: ObservableObject {
    @Published private(set) var state: TokenState

    @Published var alert: AlertItem?

    @Published var error: (any PresentableError)?

    private let tokenRepository: TokenRepository

    private let makeGitHubAPI: (String?) -> GitHubAPI

    init(tokenRepository: TokenRepository, makeGitHubAPI: @escaping (String?) -> GitHubAPI) {
        self.tokenRepository = tokenRepository
        self.state = tokenRepository.hasToken ? .saved : .empty
        self.makeGitHubAPI = makeGitHubAPI
    }

    func saveToken(_ token: String?) {
        let trimmed = token?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmed.isEmpty else {
            error = TokenInputError.emptyToken
            return
        }

        guard validateToken(trimmed) else {
            error = TokenInputError.invalidFormat
            return
        }

        do {
            try tokenRepository.saveToken(trimmed)
            state = .saved
            alert = AlertItem(title: "Success", message: "Token saved successfully!")
        } catch {
            self.error = TokenInputError.saveFailed(error)
        }
    }

    func deleteToken() {
        do {
            try tokenRepository.deleteToken()
            state = .empty
            alert = AlertItem(title: "Cleared", message: "Token removed.")
        } catch {
            self.error = TokenInputError.deleteFailed(error)
        }
    }

    func validateToken(_ token: String) -> Bool {
        token.hasPrefix("ghp_") || token.hasPrefix("github_pat_")
    }

    func makeAPIForSavedToken() throws -> GitHubAPI {
        let token = try tokenRepository.getToken()
        return makeGitHubAPI(token)
    }
}
