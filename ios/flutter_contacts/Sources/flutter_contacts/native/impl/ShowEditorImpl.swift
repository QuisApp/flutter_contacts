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
        // Not `HandlerHelpers.handleResult`: that replies with the block's return
        // value, which would answer the channel before the editor is even on screen.
        // The answer comes from `completeWithResult` once the user is done, so hold
        // the result like ShowCreatorImpl does.
        let contact: CNContact
        do {
            let store = CNContactStore()
            let keys = CNContactViewController.descriptorForRequiredKeys()
            contact = try store.unifiedContact(withIdentifier: contactId, keysToFetch: [keys])
        } catch {
            return result(HandlerHelpers.makeError(error.localizedDescription))
        }

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
            rootVC.present(navController, animated: true) {
                observeDeletion(of: contactId, in: navController)
            }
        }
    }

    /// Deleting from the editor's "Delete Contact" row never calls the delegate:
    /// the sheet stays up and the caller is left waiting on a contact that no
    /// longer exists. The store change that follows the deletion is the only
    /// signal, so close the editor once the contact is gone.
    private static func observeDeletion(
        of contactId: String,
        in navController: UINavigationController
    ) {
        storeObserver = NotificationCenter.default.addObserver(
            forName: .CNContactStoreDidChange,
            object: nil,
            queue: .main
        ) { [weak navController] _ in
            // An existence check, so fetch the identifier rather than every key
            // needed to render a contact card.
            let keys = [CNContactIdentifierKey as CNKeyDescriptor]
            let contact = try? CNContactStore().unifiedContact(withIdentifier: contactId, keysToFetch: keys)
            guard contact == nil, let navController else { return }
            // Stop observing before dismissing: `CNContactStoreDidChange` arrives in
            // bursts, and the completion below doesn't run until the dismissal
            // animation ends, so a later notification would dismiss a second time.
            removeStoreObserver()
            // Dismiss from the presenter so the delete confirmation, if it is
            // still on screen, goes away with the editor.
            let presenter = navController.presentingViewController ?? navController
            presenter.dismiss(animated: true) {
                completeWithResult(nil)
            }
        }
    }

    private static func removeStoreObserver() {
        storeObserver.map(NotificationCenter.default.removeObserver)
        storeObserver = nil
    }

    static func completeWithResult(_ value: Any?) {
        removeStoreObserver()
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
