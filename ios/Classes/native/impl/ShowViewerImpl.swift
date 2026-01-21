import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowViewerImpl {
    private static var closeHandler: ViewerCloseHandler?

    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactId: String = call.arg("contactId")!
        HandlerHelpers.handleResult(result) {
            let store = CNContactStore()
            let keys = CNContactViewController.descriptorForRequiredKeys()
            let contact = try store.unifiedContact(withIdentifier: contactId, keysToFetch: [keys])
            DispatchQueue.main.async {
                guard let rootVC = ViewControllerUtils.rootViewController() else {
                    result(HandlerHelpers.makeError("No view controller available"))
                    return
                }
                let vc = CNContactViewController(for: contact)
                vc.allowsEditing = false
                let navController = UINavigationController(rootViewController: vc)
                let handler = ViewerCloseHandler(navController: navController)
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: handler,
                    action: #selector(ViewerCloseHandler.handleClose)
                )
                closeHandler = handler
                navController.modalPresentationStyle = .pageSheet
                rootVC.present(navController, animated: true) {
                    result(nil)
                }
            }
            return nil
        }
    }

    static func clearCloseHandler() {
        closeHandler = nil
    }
}

private class ViewerCloseHandler: NSObject {
    private weak var navController: UINavigationController?

    init(navController: UINavigationController) {
        self.navController = navController
    }

    @objc func handleClose() {
        navController?.dismiss(animated: true) {
            ShowViewerImpl.clearCloseHandler()
        }
    }
}
