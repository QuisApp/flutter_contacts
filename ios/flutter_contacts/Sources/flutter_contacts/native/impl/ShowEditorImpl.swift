import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowEditorImpl {
    private static var pendingResult: FlutterResult?
    private static var editorDelegate: EditorDelegate?
    private static var closeHandler: EditorCloseHandler?
    private static var storeObserver: NSObjectProtocol?

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
                observeDeletion(of: contactId, keys: keys, in: navController)
                rootVC.present(navController, animated: true)
            }
            return nil
        }
    }

    /// Deleting from the editor's "Delete Contact" row never calls the delegate:
    /// the sheet stays up and the caller is left waiting on a contact that no
    /// longer exists. The store change that follows the deletion is the only
    /// signal, so close the editor once the contact is gone.
    private static func observeDeletion(
        of contactId: String,
        keys: CNKeyDescriptor,
        in navController: UINavigationController
    ) {
        storeObserver = NotificationCenter.default.addObserver(
            forName: .CNContactStoreDidChange,
            object: nil,
            queue: .main
        ) { [weak navController] _ in
            let store = CNContactStore()
            let contact = try? store.unifiedContact(withIdentifier: contactId, keysToFetch: [keys])
            guard contact == nil, let navController else { return }
            // Dismiss from the presenter so the delete confirmation, if it is
            // still on screen, goes away with the editor.
            let presenter = navController.presentingViewController ?? navController
            presenter.dismiss(animated: true) {
                completeWithResult(nil)
            }
        }
    }

    static func completeWithResult(_ value: Any?) {
        if let storeObserver {
            NotificationCenter.default.removeObserver(storeObserver)
        }
        storeObserver = nil
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
