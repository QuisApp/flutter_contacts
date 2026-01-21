import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowPickerImpl {
    private static var pendingResult: FlutterResult?
    private static var pickerDelegate: PickerDelegate?

    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        pendingResult = result

        DispatchQueue.main.async {
            guard let rootVC = ViewControllerUtils.rootViewController() else {
                result(HandlerHelpers.makeError("No view controller available"))
                pendingResult = nil
                return
            }

            let picker = CNContactPickerViewController()
            let delegate = PickerDelegate()
            picker.delegate = delegate
            picker.predicateForSelectionOfContact = NSPredicate(value: true)
            pickerDelegate = delegate
            rootVC.present(picker, animated: true)
        }
    }

    static func completeWithResult(_ value: Any?) {
        pendingResult?(value)
        pendingResult = nil
        pickerDelegate = nil
    }
}

private class PickerDelegate: NSObject, CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithResult(contact.identifier)
        }
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithResult(nil)
        }
    }
}
