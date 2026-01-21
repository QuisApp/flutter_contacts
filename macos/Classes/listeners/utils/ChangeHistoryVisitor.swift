import Contacts
import Foundation

class ChangeHistoryVisitor: NSObject, CNChangeHistoryEventVisitor {
    private var changes: [ContactChange] = []

    func getEvents() -> [ContactChange] {
        defer { changes.removeAll() }
        return changes
    }

    func visit(_ event: CNChangeHistoryAddContactEvent) {
        changes.append(ContactChange(type: .added, contactId: event.contact.identifier))
    }

    func visit(_ event: CNChangeHistoryUpdateContactEvent) {
        changes.append(ContactChange(type: .updated, contactId: event.contact.identifier))
    }

    func visit(_ event: CNChangeHistoryDeleteContactEvent) {
        changes.append(ContactChange(type: .removed, contactId: event.contactIdentifier))
    }

    func visit(_: CNChangeHistoryAddGroupEvent) {}
    func visit(_: CNChangeHistoryUpdateGroupEvent) {}
    func visit(_: CNChangeHistoryDeleteGroupEvent) {}
    func visit(_: CNChangeHistoryAddMemberToGroupEvent) {}
    func visit(_: CNChangeHistoryRemoveMemberFromGroupEvent) {}
    func visit(_: CNChangeHistoryAddSubgroupToGroupEvent) {}
    func visit(_: CNChangeHistoryRemoveSubgroupFromGroupEvent) {}

    // Ignore dropEverything - token will be reset naturally when updated at end
    func visit(_: CNChangeHistoryDropEverythingEvent) {}
}
