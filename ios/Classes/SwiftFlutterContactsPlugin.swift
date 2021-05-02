import Contacts
import Flutter
import UIKit

@available(iOS 9.0, *)
public enum FlutterContacts {
    // Fetches contact(s).
    static func select(
        id: String?,
        withProperties: Bool,
        withThumbnail: Bool,
        withPhoto: Bool,
        returnUnifiedContacts: Bool,
        includeNotesOnIos13AndAbove: Bool
    ) -> [[String: Any?]] {
        var contacts: [CNContact] = []
        let store = CNContactStore()
        var keys: [Any] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey,
        ]
        if withProperties {
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
            // Notes need explicit entitlement from Apple starting with iOS13.
            // https://stackoverflow.com/questions/57442114/ios-13-cncontacts-no-longer-working-to-retrieve-all-contacts
            if #available(iOS 13, *), !includeNotesOnIos13AndAbove {} else {
                keys.append(CNContactNoteKey)
            }
        }
        if withThumbnail { keys.append(CNContactThumbnailImageDataKey) }
        if withPhoto { keys.append(CNContactImageDataKey) }

        var request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        request.unifyResults = returnUnifiedContacts
        if id != nil {
            // Request for a specific contact.
            request.predicate = CNContact.predicateForContacts(withIdentifiers: [id!])
        }
        do {
            try store.enumerateContacts(
                with: request, usingBlock: { (contact, _) -> Void in
                    contacts.append(contact)
                }
            )
        } catch {
            print("Unexpected error: \(error)")
            return []
        }

        return contacts.map { Contact(fromContact: $0).toMap() }
    }

    // Inserts a new contact into the database.
    static func insert(
        _ args: [String: Any?],
        _ includeNotesOnIos13AndAbove: Bool
    ) throws -> [String: Any?] {
        let contact = CNMutableContact()

        addFieldsToContact(args, contact, includeNotesOnIos13AndAbove)

        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try CNContactStore().execute(saveRequest)
        return Contact(fromContact: contact).toMap()
    }

    // Updates an existing contact in the database.
    static func update(
        _ args: [String: Any?],
        _ includeNotesOnIos13AndAbove: Bool
    ) throws -> [String: Any?]? {
        // First, fetch the original contact.
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
        if #available(iOS 10, *) { keys.append(CNContactPhoneticOrganizationNameKey) }
        if #available(iOS 13, *), !includeNotesOnIos13AndAbove {} else {
            keys.append(CNContactNoteKey)
        }

        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        if #available(iOS 10, *) { request.mutableObjects = true }
        request.predicate = CNContact.predicateForContacts(withIdentifiers: [id])
        let store = CNContactStore()
        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request, usingBlock: { (contact, _) -> Void in
            contacts.append(contact)
        })

        // Mutate the contact
        if let firstContact = contacts.first {
            let contact = firstContact.mutableCopy() as! CNMutableContact
            clearFields(contact, includeNotesOnIos13AndAbove)
            addFieldsToContact(args, contact, includeNotesOnIos13AndAbove)

            let saveRequest = CNSaveRequest()
            saveRequest.update(contact)
            try store.execute(saveRequest)
            return Contact(fromContact: contact).toMap()
        } else {
            return nil
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
        try store.execute(saveRequest)
    }

    private static func clearFields(
        _ contact: CNMutableContact,
        _ includeNotesOnIos13AndAbove: Bool
    ) {
        contact.imageData = nil
        contact.phoneNumbers = []
        contact.emailAddresses = []
        contact.postalAddresses = []
        contact.urlAddresses = []
        contact.socialProfiles = []
        contact.instantMessageAddresses = []
        contact.dates = []
        contact.birthday = nil
        if #available(iOS 13, *), !includeNotesOnIos13AndAbove {} else {
            contact.note = ""
        }
    }

    private static func addFieldsToContact(
        _ args: [String: Any?],
        _ contact: CNMutableContact,
        _ includeNotesOnIos13AndAbove: Bool
    ) {
        Name(fromMap: args["name"] as! [String: Any]).addTo(contact)
        (args["phones"] as! [[String: Any]]).forEach {
            Phone(fromMap: $0).addTo(contact)
        }
        (args["emails"] as! [[String: Any]]).forEach {
            Email(fromMap: $0).addTo(contact)
        }
        (args["addresses"] as! [[String: Any]]).forEach {
            Address(fromMap: $0).addTo(contact)
        }
        if let organization = (args["organizations"] as! [[String: Any]]).first {
            Organization(fromMap: organization).addTo(contact)
        }
        (args["websites"] as! [[String: Any]]).forEach {
            Website(fromMap: $0).addTo(contact)
        }
        (args["socialMedias"] as! [[String: Any]]).forEach {
            SocialMedia(fromMap: $0).addTo(contact)
        }
        (args["events"] as! [[String: Any]]).forEach {
            Event(fromMap: $0).addTo(contact)
        }
        if #available(iOS 13, *), !includeNotesOnIos13AndAbove {} else {
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
        let channel = FlutterMethodChannel(
            name: "github.com/QuisApp/flutter_contacts",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "github.com/QuisApp/flutter_contacts/events",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftFlutterContactsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":
            DispatchQueue.global(qos: .userInteractive).async {
                CNContactStore().requestAccess(for: .contacts, completionHandler: { (granted, _) -> Void in
                    result(granted)
                })
            }
        case "select":
            DispatchQueue.global(qos: .userInteractive).async {
                let args = call.arguments as! [Any?]
                let id = args[0] as? String
                let withProperties = args[1] as! Bool
                let withThumbnail = args[2] as! Bool
                let withPhoto = args[3] as! Bool
                let returnUnifiedContacts = args[4] as! Bool
                // args[5] = includeNonVisibleOnAndroid
                let includeNotesOnIos13AndAbove = args[6] as! Bool
                let contacts = FlutterContacts.select(
                    id: id,
                    withProperties: withProperties,
                    withThumbnail: withThumbnail,
                    withPhoto: withPhoto,
                    returnUnifiedContacts: returnUnifiedContacts,
                    includeNotesOnIos13AndAbove: includeNotesOnIos13AndAbove
                )
                result(contacts)
            }
        case "insert":
            DispatchQueue.global(qos: .userInteractive).async {
                let args = call.arguments as! [Any?]
                let c = args[0] as! [String: Any?]
                let includeNotesOnIos13AndAbove = args[1] as! Bool
                do {
                    let contact = try FlutterContacts.insert(
                        c, includeNotesOnIos13AndAbove
                    )
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
                let args = call.arguments as! [Any?]
                let c = args[0] as! [String: Any?]
                let includeNotesOnIos13AndAbove = args[1] as! Bool
                do {
                    let contact = try FlutterContacts.update(
                        c, includeNotesOnIos13AndAbove
                    )
                    result(contact)
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

    public func onListen(
        withArguments _: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
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
