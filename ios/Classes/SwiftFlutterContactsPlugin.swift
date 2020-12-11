import Contacts
import Flutter
import UIKit

@available(iOS 9.0, *)
public enum FlutterContacts {
    static func initialize() {
        Event.initialize()
    }

    // Get contact(s)
    static func get(id: String?, withDetails: Bool, withPhotos: Bool, useHighResolutionPhotos: Bool) -> [[String: Any?]] {
        var contacts: [CNContact] = []
        let store = CNContactStore()
        var keys: [Any] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey,
        ]
        if withDetails {
            keys += [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactMiddleNameKey,
                CNContactNamePrefixKey,
                CNContactNameSuffixKey,
                CNContactNicknameKey,
                CNContactPhoneticGivenNameKey,
                CNContactPhoneticFamilyNameKey,
                CNContactPhoneticMiddleNameKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
                CNContactPostalAddressesKey,
                CNContactOrganizationNameKey,
                CNContactJobTitleKey,
                CNContactDepartmentNameKey,
                CNContactUrlAddressesKey,
                CNContactSocialProfilesKey,
                CNContactInstantMessageAddressesKey,
                CNContactBirthdayKey,
                CNContactDatesKey,
            ]
            if #available(iOS 10, *) {
                keys.append(CNContactPhoneticOrganizationNameKey)
            }
            // Notes need approval now!
            // https://stackoverflow.com/questions/57442114/ios-13-cncontacts-no-longer-working-to-retrieve-all-contacts
            if #available(iOS 13, *) {} else {
                keys.append(CNContactNoteKey)
            }
        }
        if withPhotos {
            if useHighResolutionPhotos { keys.append(CNContactImageDataKey) }
            else { keys.append(CNContactThumbnailImageDataKey) }
        }

        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        if id != nil {
            // request for a specific contact
            request.predicate = CNContact.predicateForContacts(withIdentifiers: [id!])
        }
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, _) -> Void in
                contacts.append(contact)
            })
        } catch {
            print("Unexpected error: \(error)")
            return []
        }

        return contacts.map { Contact(fromContact: $0).toMap() }
    }

    // Create new contact
    static func new(_ args: [String: Any?]) throws -> [String: Any?] {
        let contact = CNMutableContact()

        addFieldsToContact(args, contact)

        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try CNContactStore().execute(saveRequest)
        return Contact(fromContact: contact).toMap()
    }

    // Update existing contact
    static func update(_ args: [String: Any?], _ deletePhoto: Bool) throws {
        // First fetch the original contact
        let id = args["id"] as! String
        var keys: [Any] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactMiddleNameKey,
            CNContactNamePrefixKey,
            CNContactNameSuffixKey,
            CNContactNicknameKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactPhoneticMiddleNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactPostalAddressesKey,
            CNContactOrganizationNameKey,
            CNContactJobTitleKey,
            CNContactDepartmentNameKey,
            CNContactUrlAddressesKey,
            CNContactSocialProfilesKey,
            CNContactInstantMessageAddressesKey,
            CNContactBirthdayKey,
            CNContactDatesKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataKey,
        ]
        if #available(iOS 10, *) {
            keys.append(CNContactPhoneticOrganizationNameKey)
        }
        // Notes need approval now!
        // https://stackoverflow.com/questions/57442114/ios-13-cncontacts-no-longer-working-to-retrieve-all-contacts
        if #available(iOS 13, *) {} else {
            keys.append(CNContactNoteKey)
        }

        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        if #available(iOS 10, *) {
            request.mutableObjects = true
        }
        request.predicate = CNContact.predicateForContacts(withIdentifiers: [id])
        let store = CNContactStore()
        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request, usingBlock: { (contact, _) -> Void in
            contacts.append(contact)
        })

        // Mutate the contact
        if let firstContact = contacts.first {
            let contact = firstContact.mutableCopy() as! CNMutableContact
            clearFields(contact)
            addFieldsToContact(args, contact)
            if deletePhoto {
                contact.imageData = nil
            }

            let saveRequest = CNSaveRequest()
            saveRequest.update(contact)
            try CNContactStore().execute(saveRequest)
        }
    }

    // Delete contact
    static func delete(_ ids: [String]) throws {
        let request = CNContactFetchRequest(keysToFetch: [])
        if #available(iOS 10, *) {
            request.mutableObjects = true
        }
        request.predicate = CNContact.predicateForContacts(withIdentifiers: ids)
        let store = CNContactStore()
        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request, usingBlock: { (contact, _) -> Void in
            contacts.append(contact)
        })
        let saveRequest = CNSaveRequest()
        contacts.forEach { contact in
            saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
        }
        try CNContactStore().execute(saveRequest)
    }

    private static func clearFields(_ contact: CNMutableContact) {
        contact.phoneNumbers = []
        contact.emailAddresses = []
        contact.postalAddresses = []
        contact.urlAddresses = []
        contact.socialProfiles = []
        contact.instantMessageAddresses = []
        contact.dates = []
    }

    private static func addFieldsToContact(_ args: [String: Any?], _ contact: CNMutableContact) {
        Name(fromMap: args["name"] as! [String: Any]).addTo(contact)
        (args["phones"] as! [[String: Any]]).forEach { Phone(fromMap: $0).addTo(contact) }
        (args["emails"] as! [[String: Any]]).forEach { Email(fromMap: $0).addTo(contact) }
        (args["addresses"] as! [[String: Any]]).forEach { Address(fromMap: $0).addTo(contact) }
        if let organization = (args["organizations"] as! [[String: Any]]).first {
            Organization(fromMap: organization).addTo(contact)
        }
        (args["websites"] as! [[String: Any]]).forEach { Website(fromMap: $0).addTo(contact) }
        (args["socialMedias"] as! [[String: Any]]).forEach { SocialMedia(fromMap: $0).addTo(contact) }
        (args["events"] as! [[String: Any]]).forEach { Event(fromMap: $0).addTo(contact) }
        // Notes need approval now!
        // https://stackoverflow.com/questions/57442114/ios-13-cncontacts-no-longer-working-to-retrieve-all-contacts
        if #available(iOS 13, *) {} else {
            if let note = (args["notes"] as! [[String: Any]]).first {
                Note(fromMap: note).addTo(contact)
            }
        }
        if let photo = args["photo"] as? FlutterStandardTypedData {
            contact.imageData = photo.data
        }
    }
}

@available(iOS 9.0, *)
public class SwiftFlutterContactsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "github.com/QuisApp/flutter_contacts", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "github.com/QuisApp/flutter_contacts/events", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterContactsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        FlutterContacts.initialize()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "get":
            DispatchQueue.global(qos: .userInteractive).async {
                let args = call.arguments as! [Any?]
                let id = args[0] as! String?
                let withDetails = args[1] as! Bool
                let withPhotos = args[2] as! Bool
                let useHighResolutionPhotos = args[3] as! Bool
                let contacts = FlutterContacts.get(id: id, withDetails: withDetails, withPhotos: withPhotos, useHighResolutionPhotos: useHighResolutionPhotos)
                result(contacts)
            }
        case "new":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let contact = try FlutterContacts.new(call.arguments as! [String: Any?])
                    result(contact)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "update":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let args = call.arguments as! [Any]
                    let contact = args[0] as! [String: Any?]
                    let deletePhoto = args[1] as! Bool
                    try FlutterContacts.update(contact, deletePhoto)
                    result(nil)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "delete":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try FlutterContacts.delete(call.arguments as! [String])
                    result(nil)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.CNContactStoreDidChange,
            object: nil,
            queue: nil,
            using: { _ in events([]) }
        )
        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        return nil
    }
}
