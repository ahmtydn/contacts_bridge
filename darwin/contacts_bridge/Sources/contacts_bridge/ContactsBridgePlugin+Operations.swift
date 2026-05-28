#if os(macOS)
    import Cocoa
    import FlutterMacOS
#endif
#if os(iOS)
    import Flutter
    import UIKit
#endif
import Contacts
import ContactsUI

@available(iOS 9.0, macOS 10.11, *)
extension ContactsBridgePlugin {
    
    // MARK: - Core Contact Operations
    
    func getAllContacts(
        withProperties: Bool = true,
        withThumbnail: Bool = false,
        withPhoto: Bool = false,
        sorted: Bool = true
    ) throws -> [CNContact] {
        let store = CNContactStore()
        var keys: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey as CNKeyDescriptor,
        ]
        
        if withProperties {
            let propertyKeys: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactNameSuffixKey as CNKeyDescriptor,
                CNContactNicknameKey as CNKeyDescriptor,
                CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPostalAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactJobTitleKey as CNKeyDescriptor,
                CNContactDepartmentNameKey as CNKeyDescriptor,
                CNContactUrlAddressesKey as CNKeyDescriptor,
                CNContactSocialProfilesKey as CNKeyDescriptor,
                CNContactInstantMessageAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactDatesKey as CNKeyDescriptor
            ]
            keys += propertyKeys
            
            if #available(iOS 10, macOS 10.12, *) {
                keys.append(CNContactPhoneticOrganizationNameKey as CNKeyDescriptor)
            }
        }
        
        if withThumbnail {
            keys.append(CNContactThumbnailImageDataKey as CNKeyDescriptor)
        }
        
        if withPhoto {
            keys.append(CNContactImageDataKey as CNKeyDescriptor)
        }
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.unifyResults = true
        
        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request) { (contact, _) in
            contacts.append(contact)
        }
        
        if sorted {
            contacts.sort { (contact1, contact2) in
                let name1 = CNContactFormatter.string(from: contact1, style: .fullName) ?? ""
                let name2 = CNContactFormatter.string(from: contact2, style: .fullName) ?? ""
                return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
            }
        }
        
        return contacts
    }
    
    func getContact(
        id: String,
        withProperties: Bool = true,
        withThumbnail: Bool = false,
        withPhoto: Bool = false
    ) throws -> CNContact? {
        let store = CNContactStore()
        var keys: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey as CNKeyDescriptor,
        ]
        
        if withProperties {
            let propertyKeys: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactNameSuffixKey as CNKeyDescriptor,
                CNContactNicknameKey as CNKeyDescriptor,
                CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPostalAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactJobTitleKey as CNKeyDescriptor,
                CNContactDepartmentNameKey as CNKeyDescriptor,
                CNContactUrlAddressesKey as CNKeyDescriptor,
                CNContactSocialProfilesKey as CNKeyDescriptor,
                CNContactInstantMessageAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactDatesKey as CNKeyDescriptor
            ]
            keys += propertyKeys
            
            if #available(iOS 10, macOS 10.12, *) {
                keys.append(CNContactPhoneticOrganizationNameKey as CNKeyDescriptor)
            }
        }
        
        if withThumbnail {
            keys.append(CNContactThumbnailImageDataKey as CNKeyDescriptor)
        }
        
        if withPhoto {
            keys.append(CNContactImageDataKey as CNKeyDescriptor)
        }
        
        let predicate = CNContact.predicateForContacts(withIdentifiers: [id])
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
        return contacts.first
    }
    
    func searchContacts(
        query: String,
        withProperties: Bool = false,
        sorted: Bool = true
    ) throws -> [CNContact] {
        let store = CNContactStore()
        var keys: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey as CNKeyDescriptor,
        ]
        
        if withProperties {
            let propertyKeys: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactNameSuffixKey as CNKeyDescriptor,
                CNContactNicknameKey as CNKeyDescriptor,
                CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPostalAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactJobTitleKey as CNKeyDescriptor,
                CNContactDepartmentNameKey as CNKeyDescriptor,
                CNContactUrlAddressesKey as CNKeyDescriptor,
                CNContactSocialProfilesKey as CNKeyDescriptor,
                CNContactInstantMessageAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactDatesKey as CNKeyDescriptor
            ]
            keys += propertyKeys
        }
        
        let predicate = CNContact.predicateForContacts(matchingName: query)
        var contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
        
        if sorted {
            contacts.sort { (contact1, contact2) in
                let name1 = CNContactFormatter.string(from: contact1, style: .fullName) ?? ""
                let name2 = CNContactFormatter.string(from: contact2, style: .fullName) ?? ""
                return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
            }
        }
        
        return contacts
    }
    
    func createContact(from data: [String: Any]) throws -> CNContact {
        let store = CNContactStore()
        let mutableContact = CNMutableContact()
        
        // Basic information
        if let givenName = data["givenName"] as? String {
            mutableContact.givenName = givenName
        }
        
        if let familyName = data["familyName"] as? String {
            mutableContact.familyName = familyName
        }
        
        if let middleName = data["middleName"] as? String {
            mutableContact.middleName = middleName
        }
        
        if let namePrefix = data["namePrefix"] as? String {
            mutableContact.namePrefix = namePrefix
        }
        
        if let nameSuffix = data["nameSuffix"] as? String {
            mutableContact.nameSuffix = nameSuffix
        }
        
        if let nickname = data["nickname"] as? String {
            mutableContact.nickname = nickname
        }
        
        if let organizationName = data["organizationName"] as? String {
            mutableContact.organizationName = organizationName
        }
        
        if let jobTitle = data["jobTitle"] as? String {
            mutableContact.jobTitle = jobTitle
        }
        
        if let departmentName = data["departmentName"] as? String {
            mutableContact.departmentName = departmentName
        }
        
        // Phone numbers
        if let phoneNumbers = data["phoneNumbers"] as? [[String: Any]] {
            mutableContact.phoneNumbers = phoneNumbers.compactMap { phoneData in
                guard let number = phoneData["number"] as? String else { return nil }
                let label = phoneData["label"] as? String ?? CNLabelPhoneNumberMain
                return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: number))
            }
        }
        
        // Email addresses
        if let emailAddresses = data["emailAddresses"] as? [[String: Any]] {
            mutableContact.emailAddresses = emailAddresses.compactMap { emailData in
                guard let email = emailData["email"] as? String else { return nil }
                let label = emailData["label"] as? String ?? CNLabelHome
                return CNLabeledValue(label: label, value: email as NSString)
            }
        }
        
        // Postal addresses
        if let postalAddresses = data["postalAddresses"] as? [[String: Any]] {
            mutableContact.postalAddresses = postalAddresses.compactMap { addressData in
                let address = CNMutablePostalAddress()
                address.street = addressData["street"] as? String ?? ""
                address.city = addressData["city"] as? String ?? ""
                address.state = addressData["state"] as? String ?? ""
                address.postalCode = addressData["postalCode"] as? String ?? ""
                address.country = addressData["country"] as? String ?? ""
                
                let label = addressData["label"] as? String ?? CNLabelHome
                return CNLabeledValue(label: label, value: address)
            }
        }
        
        // URLs
        if let urlAddresses = data["urlAddresses"] as? [[String: Any]] {
            mutableContact.urlAddresses = urlAddresses.compactMap { urlData in
                guard let url = urlData["url"] as? String else { return nil }
                let label = urlData["label"] as? String ?? CNLabelURLAddressHomePage
                return CNLabeledValue(label: label, value: url as NSString)
            }
        }
        
        // Note
        if let note = data["note"] as? String {
            mutableContact.note = note
        }
        
        // Birthday
        if let birthdayData = data["birthday"] as? [String: Any],
           let year = birthdayData["year"] as? Int,
           let month = birthdayData["month"] as? Int,
           let day = birthdayData["day"] as? Int {
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            mutableContact.birthday = dateComponents
        }
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        
        try store.execute(saveRequest)
        
        // Return the saved contact with its new identifier
        return try fetchContact(id: mutableContact.identifier, withProperties: true) ?? mutableContact
    }
    
    func updateContact(from data: [String: Any]) throws -> CNContact {
        guard let contactId = data["id"] as? String else {
            throw ContactsBridgeError.invalidContactData("Contact ID is required for update")
        }
        
        let store = CNContactStore()
        guard let existingContact = try fetchContact(id: contactId, withProperties: true) else {
            throw ContactsBridgeError.contactNotFound("Contact not found with ID: \(contactId)")
        }
        
        let mutableContact = existingContact.mutableCopy() as! CNMutableContact
        
        // Update basic information
        if let givenName = data["givenName"] as? String {
            mutableContact.givenName = givenName
        }
        
        if let familyName = data["familyName"] as? String {
            mutableContact.familyName = familyName
        }
        
        if let middleName = data["middleName"] as? String {
            mutableContact.middleName = middleName
        }
        
        if let namePrefix = data["namePrefix"] as? String {
            mutableContact.namePrefix = namePrefix
        }
        
        if let nameSuffix = data["nameSuffix"] as? String {
            mutableContact.nameSuffix = nameSuffix
        }
        
        if let nickname = data["nickname"] as? String {
            mutableContact.nickname = nickname
        }
        
        if let organizationName = data["organizationName"] as? String {
            mutableContact.organizationName = organizationName
        }
        
        if let jobTitle = data["jobTitle"] as? String {
            mutableContact.jobTitle = jobTitle
        }
        
        if let departmentName = data["departmentName"] as? String {
            mutableContact.departmentName = departmentName
        }
        
        // Update phone numbers
        if let phoneNumbers = data["phoneNumbers"] as? [[String: Any]] {
            mutableContact.phoneNumbers = phoneNumbers.compactMap { phoneData in
                guard let number = phoneData["number"] as? String else { return nil }
                let label = phoneData["label"] as? String ?? CNLabelPhoneNumberMain
                return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: number))
            }
        }
        
        // Update email addresses
        if let emailAddresses = data["emailAddresses"] as? [[String: Any]] {
            mutableContact.emailAddresses = emailAddresses.compactMap { emailData in
                guard let email = emailData["email"] as? String else { return nil }
                let label = emailData["label"] as? String ?? CNLabelHome
                return CNLabeledValue(label: label, value: email as NSString)
            }
        }
        
        // Update note
        if let note = data["note"] as? String {
            mutableContact.note = note
        }
        
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)
        
        try store.execute(saveRequest)
        
        return try fetchContact(id: contactId, withProperties: true) ?? mutableContact
    }
    
    func deleteContact(id: String) throws {
        let store = CNContactStore()
        guard let contact = try fetchContact(id: id) else {
            throw ContactsBridgeError.contactNotFound("Contact not found with ID: \(id)")
        }
        
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutableContact)
        
        try store.execute(saveRequest)
    }
    
    // MARK: - Helper Methods
    
    func fetchContact(id: String, withProperties: Bool = true) throws -> CNContact? {
        return try getContact(id: id, withProperties: withProperties)
    }
}

// MARK: - Custom Errors

enum ContactsBridgeError: Error {
    case permissionDenied(String)
    case contactNotFound(String)
    case invalidContactData(String)
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .contactNotFound(let message):
            return "Contact not found: \(message)"
        case .invalidContactData(let message):
            return "Invalid contact data: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}