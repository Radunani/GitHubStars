protocol PresentableError: Error {
    var alertTitle: String { get }
    var alertMessage: String { get }
}
