import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowCreatorImpl {
    private static var pendingResult: FlutterResult?
    private static var creatorDelegate: CreatorDelegate?

    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // One creator at a time. The pending result and delegate are single statics, so a
        // second call would strand the first caller's Future and overwrite `creatorDelegate`
        // — and since `CNContactViewController` holds its delegate weakly, the creator
        // already on screen would lose it and never be able to complete. Reject the new call
        // rather than break the live one.
        guard pendingResult == nil else {
            return result(HandlerHelpers.makeError("A creator is already presented"))
        }
        let contactJson: Json? = call.arg("contact")
        let newContact = contactJson.map { ContactBuilder.toCNMutableContact(Contact.fromJson($0)) } ?? CNMutableContact()

        pendingResult = result

        DispatchQueue.main.async {
            guard let rootVC = ViewControllerUtils.rootViewController() else {
                result(HandlerHelpers.makeError("No view controller available"))
                pendingResult = nil
                return
            }

            let vc = CNContactViewController(forNewContact: newContact)
            let delegate = CreatorDelegate()
            vc.delegate = delegate
            creatorDelegate = delegate
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .pageSheet
            rootVC.present(navController, animated: true)
        }
    }

    static func completeWithResult(_ value: Any?) {
        pendingResult?(value)
        pendingResult = nil
        creatorDelegate = nil
    }
}

private class CreatorDelegate: NSObject, CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true) {
            ShowCreatorImpl.completeWithResult(contact?.identifier)
        }
    }
}
