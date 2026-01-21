import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowEditorImpl {
    private static var pendingResult: FlutterResult?
    private static var editorDelegate: EditorDelegate?
    private static var closeHandler: EditorCloseHandler?

    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let contactId: String = call.arg("contactId")!
        HandlerHelpers.handleResult(result) {
            let store = CNContactStore()
            let keys = CNContactViewController.descriptorForRequiredKeys()
            let contact = try store.unifiedContact(withIdentifier: contactId, keysToFetch: [keys])
            pendingResult = result
            DispatchQueue.main.async {
                guard let rootVC = ViewControllerUtils.rootViewController() else {
                    result(HandlerHelpers.makeError("No view controller available"))
                    pendingResult = nil
                    return
                }
                let vc = CNContactViewController(for: contact)
                vc.allowsEditing = true
                let delegate = EditorDelegate()
                vc.delegate = delegate
                let navController = UINavigationController(rootViewController: vc)
                let handler = EditorCloseHandler(navController: navController)
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: handler,
                    action: #selector(EditorCloseHandler.handleClose)
                )
                editorDelegate = delegate
                closeHandler = handler
                navController.modalPresentationStyle = .pageSheet
                rootVC.present(navController, animated: true)
            }
            return nil
        }
    }

    static func completeWithResult(_ value: Any?) {
        pendingResult?(value)
        pendingResult = nil
        editorDelegate = nil
        closeHandler = nil
    }
}

private class EditorDelegate: NSObject, CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true) {
            ShowEditorImpl.completeWithResult(contact?.identifier)
        }
    }
}

private class EditorCloseHandler: NSObject {
    private weak var navController: UINavigationController?

    init(navController: UINavigationController) {
        self.navController = navController
    }

    @objc func handleClose() {
        navController?.dismiss(animated: true) {
            ShowEditorImpl.completeWithResult(nil)
        }
    }
}
