#if os(iOS)
import Flutter
import UIKit
import Contacts
import ContactsUI

@available(iOS 9.0, *)
@available(macOS, unavailable)
public class ContactViewIOS: NSObject, CNContactViewControllerDelegate, CNContactPickerDelegate {

    private let flutterContactsPlugin: FlutterContactsPlugin
    public var rootViewController: UIViewController

    init(_ flutterContactsPlugin: FlutterContactsPlugin) {
        self.flutterContactsPlugin = flutterContactsPlugin;
        rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
    }

    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) { 
        if let result = flutterContactsPlugin.externalResult {
            result(contact?.identifier)
            flutterContactsPlugin.externalResult = nil
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    public func contactPicker(_: CNContactPickerViewController, didSelect contact: CNContact) {
        if let result = flutterContactsPlugin.externalResult {
            result(contact.identifier)
            flutterContactsPlugin.externalResult = nil
        }
    }

    // public func contactPicker(_: CNContactPicker, didSelect contact: CNContact) {
    //     if let result = flutterContactsPlugin.externalResult {
    //         result(contact.identifier)
    //         flutterContactsPlugin.externalResult = nil
    //     }
    // }

    public func contactPickerDidCancel(_: CNContactPickerViewController) {
        if let result = flutterContactsPlugin.externalResult {
            result(nil)
            flutterContactsPlugin.externalResult = nil
        }
    }

    // public func contactPickerDidCancel(_: CNContactPicker) {
    //     if let result = flutterContactsPlugin.externalResult {
    //         result(nil)
    //         flutterContactsPlugin.externalResult = nil
    //     }
    // }
}
#endif
