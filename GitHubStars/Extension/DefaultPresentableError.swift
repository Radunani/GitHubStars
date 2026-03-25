import Foundation

struct DefaultPresentableError: PresentableError {
    let error: Error

    init(_ error: Error) {
        self.error = error
    }

    var alertTitle: String { "Error" }

    var alertMessage: String {
        (error as? LocalizedError)?.errorDescription
        ?? error.localizedDescription
    }
}
