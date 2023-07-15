import Contacts
import ContactsUI
import Flutter
import UIKit

@available(iOS 9.0, *)
public enum FlutterContacts {
    // Fetches contact(s).
    static func selectInternal(
        store: CNContactStore,
        id: String?,
        withProperties: Bool,
        withThumbnail: Bool,
        withPhoto: Bool,
        returnUnifiedContacts: Bool,
        includeNotesOnIos13AndAbove: Bool,
        externalIntent: Bool = false
    ) -> [CNContact] {
        var contacts: [CNContact] = []
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
            if externalIntent {
                keys.append(CNContactViewController.descriptorForRequiredKeys())
            }
        }
        if withThumbnail { keys.append(CNContactThumbnailImageDataKey) }
        if withPhoto { keys.append(CNContactImageDataKey) }

        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
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

        return contacts
    }

    static func select(
        id: String?,
        withProperties: Bool,
        withThumbnail: Bool,
        withPhoto: Bool,
        withGroups: Bool,
        withAccounts: Bool,
        returnUnifiedContacts: Bool,
        includeNotesOnIos13AndAbove: Bool
    ) -> [[String: Any?]] {
        let store = CNContactStore()
        let contactsInternal = selectInternal(
            store: store,
            id: id,
            withProperties: withProperties,
            withThumbnail: withThumbnail,
            withPhoto: withPhoto,
            returnUnifiedContacts: returnUnifiedContacts,
            includeNotesOnIos13AndAbove: includeNotesOnIos13AndAbove
        )
        var contacts = contactsInternal.map { Contact(fromContact: $0) }
        if withGroups {
            let groups = fetchGroups(store)
            let groupMemberships = fetchGroupMemberships(store, groups)
            for (index, contact) in contacts.enumerated() {
                if let contactGroups = groupMemberships[contact.id] {
                    contacts[index].groups = contactGroups.map { Group(fromGroup: groups[$0]) }
                }
            }
        }
        if withAccounts {
            let containers = fetchContainers(store)
            let containerMemberships = fetchContainerMemberships(store, containers)
            for (index, contact) in contacts.enumerated() {
                if let contactContainers = containerMemberships[contact.id] {
                    contacts[index].accounts = contactContainers.map { Account(fromContainer: containers[$0]) }
                }
            }
        }
        return contacts.map { $0.toMap() }
    }

    static func fetchGroups(_ store: CNContactStore) -> [CNGroup] {
        var groups: [CNGroup] = []
        do {
            try groups = store.groups(matching: nil)
        } catch {
            print("Unexpected error: \(error)")
            return []
        }
        return groups
    }

    static func fetchGroupMemberships(_ store: CNContactStore, _ groups: [CNGroup], forContactId contactId: String? = nil) -> [String: [Int]] {
        var memberships = [String: [Int]]()
        for (groupIndex, group) in groups.enumerated() {
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey] as [CNKeyDescriptor])
            request.predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
            do {
                try store.enumerateContacts(with: request) { (contact, _) -> Void in
                    if contactId == nil || contact.identifier == contactId {
                        if let contactGroups = memberships[contact.identifier] {
                            memberships[contact.identifier] = contactGroups + [groupIndex]
                        } else {
                            memberships[contact.identifier] = [groupIndex]
                        }
                    }
                }
            } catch {
                print("Unexpected error: \(error)")
            }
        }
        return memberships
    }

    static func fetchContainers(_ store: CNContactStore) -> [CNContainer] {
        var containers: [CNContainer] = []
        do {
            try containers = store.containers(matching: nil)
        } catch {
            print("Unexpected error: \(error)")
            return []
        }
        return containers
    }

    static func fetchContainerMemberships(_ store: CNContactStore, _ containers: [CNContainer]) -> [String: [Int]] {
        var memberships = [String: [Int]]()
        for (containerIndex, container) in containers.enumerated() {
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey] as [CNKeyDescriptor])
            request.predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                try store.enumerateContacts(with: request) { (contact, _) -> Void in
                    if let contactContainers = memberships[contact.identifier] {
                        memberships[contact.identifier] = contactContainers + [containerIndex]
                    } else {
                        memberships[contact.identifier] = [containerIndex]
                    }
                }
            } catch {
                print("Unexpected error: \(error)")
            }
        }
        return memberships
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
        _ withGroups: Bool,
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

            // Update group membership
            if withGroups {
                let groups = fetchGroups(store)
                let groupMemberships = fetchGroupMemberships(store, groups, forContactId: contact.identifier)
                for groupIndex in groupMemberships[contact.identifier] ?? [] {
                    let deleteRequest = CNSaveRequest()
                    deleteRequest.removeMember(contact, from: groups[groupIndex])
                    try store.execute(deleteRequest)
                }

                let groupIds = Set((args["groups"] as! [[String: Any]]).map { Group(fromMap: $0).id })
                for group in groups {
                    if groupIds.contains(group.identifier) {
                        let addRequest = CNSaveRequest()
                        addRequest.addMember(contact, to: group)
                        try store.execute(addRequest)
                    }
                }
            }

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

    static func getGroups() -> [[String: Any]] {
        let store = CNContactStore()
        let groups = fetchGroups(store)
        return groups.map { Group(fromGroup: $0).toMap() }
    }

    static func insertGroup(_ args: [String: Any]) throws -> [String: Any] {
        let group = Group(fromMap: args)
        let newGroup = CNMutableGroup()
        newGroup.name = group.name

        let saveRequest = CNSaveRequest()
        saveRequest.add(newGroup, toContainerWithIdentifier: nil)
        try CNContactStore().execute(saveRequest)

        return Group(fromGroup: newGroup).toMap()
    }

    static func updateGroup(_ args: [String: Any]) throws -> [String: Any] {
        let group = Group(fromMap: args)

        let store = CNContactStore()
        let groups = fetchGroups(store)

        for g in groups {
            if g.identifier == group.id {
                let updatedGroup = g.mutableCopy() as! CNMutableGroup
                updatedGroup.name = group.name

                let saveRequest = CNSaveRequest()
                saveRequest.update(updatedGroup)
                try CNContactStore().execute(saveRequest)

                return Group(fromGroup: updatedGroup).toMap()
            }
        }

        return args
    }

    static func deleteGroup(_ args: [String: Any]) throws {
        let group = Group(fromMap: args)

        let store = CNContactStore()
        let groups = fetchGroups(store)

        for g in groups {
            if g.identifier == group.id {
                let deletedGroup = g.mutableCopy() as! CNMutableGroup

                let saveRequest = CNSaveRequest()
                saveRequest.delete(deletedGroup)
                try CNContactStore().execute(saveRequest)

                return
            }
        }
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

    static func addFieldsToContact(
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
public class SwiftFlutterContactsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CNContactViewControllerDelegate, CNContactPickerDelegate {
    private let rootViewController: UIViewController
    private var externalResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "github.com/QuisApp/flutter_contacts",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "github.com/QuisApp/flutter_contacts/events",
            binaryMessenger: registrar.messenger()
        )
        let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
        let instance = SwiftFlutterContactsPlugin(rootViewController)
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
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
                let withGroups = args[4] as! Bool
                let withAccounts = args[5] as! Bool
                let returnUnifiedContacts = args[6] as! Bool
                // args[7] = includeNonVisibleOnAndroid
                let includeNotesOnIos13AndAbove = args[8] as! Bool
                let contacts = FlutterContacts.select(
                    id: id,
                    withProperties: withProperties,
                    withThumbnail: withThumbnail,
                    withPhoto: withPhoto,
                    withGroups: withGroups,
                    withAccounts: withAccounts,
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
                let withGroups = args[1] as! Bool
                let includeNotesOnIos13AndAbove = args[2] as! Bool
                do {
                    let contact = try FlutterContacts.update(
                        c, withGroups, includeNotesOnIos13AndAbove
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
        case "getGroups":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let groups = try FlutterContacts.getGroups()
                    result(groups)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "insertGroup":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let args = call.arguments as! [Any?]
                    let g = args[0] as! [String: Any]
                    let group = try FlutterContacts.insertGroup(g)
                    result(group)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "updateGroup":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let args = call.arguments as! [Any?]
                    let g = args[0] as! [String: Any]
                    let group = try FlutterContacts.updateGroup(g)
                    result(group)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "deleteGroup":
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let args = call.arguments as! [Any?]
                    let g = args[0] as! [String: Any]
                    try FlutterContacts.deleteGroup(g)
                    result(nil)
                } catch {
                    result(FlutterError(
                        code: "unknown error",
                        message: "unknown error",
                        details: error.localizedDescription
                    ))
                }
            }
        case "openExternalViewOrEdit":
            DispatchQueue.main.async {
                let args = call.arguments as! [Any?]
                let id = args[0] as! String
                let contacts = FlutterContacts.selectInternal(
                    store: CNContactStore(),
                    id: id,
                    withProperties: true,
                    withThumbnail: true,
                    withPhoto: true,
                    returnUnifiedContacts: true,
                    includeNotesOnIos13AndAbove: false,
                    externalIntent: true
                )
                if !contacts.isEmpty {
                    let contactView = CNContactViewController(for: contacts.first!)
                    contactView.navigationItem.backBarButtonItem = UIBarButtonItem(
                        title: "Back",
                        style: .plain,
                        target: self,
                        action: #selector(self.contactViewControllerDidCancel)
                    )
                    contactView.delegate = self
                    // https://stackoverflow.com/a/39594589
                    let navigationController = UINavigationController(rootViewController: contactView)
                    self.rootViewController.present(navigationController, animated: true, completion: nil)
                    self.externalResult = result
                }
            }
        case "openExternalPick":
            DispatchQueue.main.async {
                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = self
                self.rootViewController.present(contactPicker, animated: true, completion: nil)
                self.externalResult = result
            }
        case "openExternalInsert":
            DispatchQueue.main.async {
                let contact = CNMutableContact()
                let args = call.arguments as? [Any?]
                // Check if we have contact data to insert
                if args?.count ?? 0 > 0 {
                    let contactData = args![0] as? [String: Any?]
                    if !(contactData?.isEmpty ?? true) {
                        FlutterContacts.addFieldsToContact(contactData!, contact, false)
                    }
                }
                let contactView = CNContactViewController(forNewContact: contact)
                contactView.navigationItem.backBarButtonItem = UIBarButtonItem(
                    title: "Cancel",
                    style: .plain,
                    target: self,
                    action: #selector(self.contactViewControllerDidCancel)
                )
                contactView.delegate = self
                // https://stackoverflow.com/a/39594589
                let navigationController = UINavigationController(rootViewController: contactView)
                self.rootViewController.present(navigationController, animated: true, completion: nil)
                self.externalResult = result
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

    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if let result = externalResult {
            result(contact?.identifier)
            externalResult = nil
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    @objc func contactViewControllerDidCancel() {
        if let result = externalResult {
            let viewController: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
            viewController?.dismiss(animated: true, completion: nil)
            result(nil)
            externalResult = nil
        }
    }

    public func contactPicker(_: CNContactPickerViewController, didSelect contact: CNContact) {
        if let result = externalResult {
            result(contact.identifier)
            externalResult = nil
        }
    }

    public func contactPickerDidCancel(_: CNContactPickerViewController) {
        if let result = externalResult {
            result(nil)
            externalResult = nil
        }
    }
}
