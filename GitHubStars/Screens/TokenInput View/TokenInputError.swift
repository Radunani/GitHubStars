import UIKit

enum TokenInputError: PresentableError {
    case emptyToken
    case invalidFormat
    case saveFailed(Error)
    case deleteFailed(Error)

    var alertTitle: String {
        switch self {
        case .invalidFormat:
            return "Invalid Token"
        default:
            return "Error"
        }
    }

    var alertMessage: String {
        switch self {
        case .emptyToken:
            return "Please enter a valid token"
        case .invalidFormat:
            return "GitHub tokens usually start with 'ghp_' or 'github_pat_'"
        case .saveFailed(let error):
            return "Failed to save token: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to clear token: \(error.localizedDescription)"
        }
    }
}
