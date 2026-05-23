import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowPickerImpl {
    private static var pendingResult: FlutterResult?
    private static var pickerDelegate: PickerDelegate?
    private static var requestedProperties: Set<String> = []
    private static var enableIosNotes = false

    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        pendingResult = result
        requestedProperties = Set(call.argList("properties") as [String]? ?? [])
        enableIosNotes = call.arg("enableIosNotes", default: false)

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

    static func completeWithContact(_ contact: CNContact?) {
        pendingResult?(contact.map {
            ContactConverter.toJson($0, options: ContactConverter.makeOptions(properties: requestedProperties, enableIosNotes: enableIosNotes))
        })
        pendingResult = nil
        pickerDelegate = nil
    }
}

private class PickerDelegate: NSObject, CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithContact(contact)
        }
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithContact(nil)
        }
    }
}
