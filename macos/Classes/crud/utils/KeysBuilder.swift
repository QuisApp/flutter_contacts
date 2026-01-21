import Contacts

private extension String {
    var k: CNKeyDescriptor { self as CNKeyDescriptor }
}

enum KeysBuilder {
    static func build(properties: Set<String>) -> [CNKeyDescriptor] {
        let has = properties.contains
        var keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey.k,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        ]

        if has("name") {
            keys.append(contentsOf: [
                CNContactNamePrefixKey.k, CNContactNameSuffixKey.k,
                CNContactPhoneticGivenNameKey.k, CNContactPhoneticMiddleNameKey.k, CNContactPhoneticFamilyNameKey.k,
                CNContactPreviousFamilyNameKey.k, CNContactNicknameKey.k,
            ])
        }

        if has("phone") { keys.append(CNContactPhoneNumbersKey.k) }
        if has("email") { keys.append(CNContactEmailAddressesKey.k) }
        if has("address") { keys.append(CNContactPostalAddressesKey.k) }
        if has("organization") {
            keys.append(contentsOf: [
                CNContactOrganizationNameKey.k, CNContactJobTitleKey.k,
                CNContactDepartmentNameKey.k, CNContactPhoneticOrganizationNameKey.k,
            ])
        }
        if has("website") { keys.append(CNContactUrlAddressesKey.k) }
        if has("socialMedia") {
            keys.append(contentsOf: [
                CNContactSocialProfilesKey.k,
                CNContactInstantMessageAddressesKey.k,
            ])
        }
        if has("event") {
            keys.append(contentsOf: [
                CNContactBirthdayKey.k,
                CNContactDatesKey.k,
            ])
        }
        if has("relation") { keys.append(CNContactRelationsKey.k) }
        if has("note") { keys.append(CNContactNoteKey.k) }

        let wantsThumbnail = has("photoThumbnail")
        let wantsFullRes = has("photoFullRes")
        if wantsThumbnail || wantsFullRes {
            keys.append(CNContactImageDataAvailableKey.k)
            if wantsThumbnail {
                keys.append(CNContactThumbnailImageDataKey.k)
            }
            if wantsFullRes {
                keys.append(CNContactImageDataKey.k)
            }
        }

        return keys
    }

    static func buildForUpdate(properties _: Set<String>) -> [CNKeyDescriptor] {
        let keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey.k,
            CNContactTypeKey.k,
            CNContactGivenNameKey.k,
            CNContactMiddleNameKey.k,
            CNContactFamilyNameKey.k,
            CNContactNamePrefixKey.k,
            CNContactNameSuffixKey.k,
            CNContactPhoneticGivenNameKey.k,
            CNContactPhoneticMiddleNameKey.k,
            CNContactPhoneticFamilyNameKey.k,
            CNContactPreviousFamilyNameKey.k,
            CNContactNicknameKey.k,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey.k,
            CNContactEmailAddressesKey.k,
            CNContactPostalAddressesKey.k,
            CNContactOrganizationNameKey.k,
            CNContactJobTitleKey.k,
            CNContactDepartmentNameKey.k,
            CNContactPhoneticOrganizationNameKey.k,
            CNContactUrlAddressesKey.k,
            CNContactSocialProfilesKey.k,
            CNContactInstantMessageAddressesKey.k,
            CNContactBirthdayKey.k,
            CNContactNonGregorianBirthdayKey.k,
            CNContactDatesKey.k,
            CNContactRelationsKey.k,
            CNContactNoteKey.k,
            CNContactImageDataAvailableKey.k,
            CNContactThumbnailImageDataKey.k,
            CNContactImageDataKey.k,
        ]

        return keys
    }
}
