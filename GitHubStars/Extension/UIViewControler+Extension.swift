import UIKit

extension UIViewController {
    func showErrorAlert(error: Error) {
        let presentable: PresentableError
        if let error = error as? PresentableError {
            presentable = error
        } else {
            presentable = DefaultPresentableError(error)
        }

        showAlert(title: presentable.alertTitle, message: presentable.alertMessage)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
