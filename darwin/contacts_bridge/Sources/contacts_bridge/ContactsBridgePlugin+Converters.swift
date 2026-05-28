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
    
    // MARK: - Data Conversion
    
    func contactToDict(_ contact: CNContact) -> [String: Any?] {
        var dict: [String: Any?] = [:]
        
        // Basic information
        dict["id"] = contact.identifier
        dict["displayName"] = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        
        // Name components - safely access properties
        var nameDict: [String: Any?] = [:]
        if contact.isKeyAvailable(CNContactGivenNameKey) {
            nameDict["givenName"] = contact.givenName
        }
        if contact.isKeyAvailable(CNContactFamilyNameKey) {
            nameDict["familyName"] = contact.familyName
        }
        if contact.isKeyAvailable(CNContactMiddleNameKey) {
            nameDict["middleName"] = contact.middleName
        }
        if contact.isKeyAvailable(CNContactNamePrefixKey) {
            nameDict["namePrefix"] = contact.namePrefix
        }
        if contact.isKeyAvailable(CNContactNameSuffixKey) {
            nameDict["nameSuffix"] = contact.nameSuffix
        }
        if contact.isKeyAvailable(CNContactNicknameKey) {
            nameDict["nickname"] = contact.nickname
        }
        if contact.isKeyAvailable(CNContactPhoneticGivenNameKey) {
            nameDict["phoneticGivenName"] = contact.phoneticGivenName
        }
        if contact.isKeyAvailable(CNContactPhoneticFamilyNameKey) {
            nameDict["phoneticFamilyName"] = contact.phoneticFamilyName
        }
        if contact.isKeyAvailable(CNContactPhoneticMiddleNameKey) {
            nameDict["phoneticMiddleName"] = contact.phoneticMiddleName
        }
        dict["name"] = nameDict
        
        // Organization - safely access properties
        var orgDict: [String: Any?] = [:]
        if contact.isKeyAvailable(CNContactOrganizationNameKey) {
            orgDict["name"] = contact.organizationName
        }
        if contact.isKeyAvailable(CNContactJobTitleKey) {
            orgDict["jobTitle"] = contact.jobTitle
        }
        if contact.isKeyAvailable(CNContactDepartmentNameKey) {
            orgDict["department"] = contact.departmentName
        }
        dict["organization"] = orgDict
        
        // Phone numbers - safely access
        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            dict["phones"] = contact.phoneNumbers.map { phoneNumber in
                return [
                    "number": phoneNumber.value.stringValue,
                    "label": CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneNumber.label ?? ""),
                    "normalizedNumber": phoneNumber.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                ]
            }
        } else {
            dict["phones"] = []
        }
        
        // Email addresses - safely access
        if contact.isKeyAvailable(CNContactEmailAddressesKey) {
            dict["emails"] = contact.emailAddresses.map { email in
                return [
                    "email": email.value as String,
                    "label": CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? "")
                ]
            }
        } else {
            dict["emails"] = []
        }
        
        // Postal addresses - safely access
        if contact.isKeyAvailable(CNContactPostalAddressesKey) {
            dict["addresses"] = contact.postalAddresses.map { address in
                let postalAddress = address.value
                return [
                    "label": CNLabeledValue<CNPostalAddress>.localizedString(forLabel: address.label ?? ""),
                    "street": postalAddress.street,
                    "city": postalAddress.city,
                    "state": postalAddress.state,
                    "postalCode": postalAddress.postalCode,
                    "country": postalAddress.country,
                    "isoCountryCode": postalAddress.isoCountryCode
                ]
            }
        } else {
            dict["addresses"] = []
        }
        
        // URLs - safely access
        if contact.isKeyAvailable(CNContactUrlAddressesKey) {
            dict["websites"] = contact.urlAddresses.map { url in
                return [
                    "url": url.value as String,
                    "label": CNLabeledValue<NSString>.localizedString(forLabel: url.label ?? "")
                ]
            }
        } else {
            dict["websites"] = []
        }
        
        // Social profiles - safely access
        if contact.isKeyAvailable(CNContactSocialProfilesKey) {
            dict["socialProfiles"] = contact.socialProfiles.map { profile in
                let socialProfile = profile.value
                return [
                    "service": socialProfile.service,
                    "username": socialProfile.username,
                    "userIdentifier": socialProfile.userIdentifier,
                    "url": socialProfile.urlString,
                    "label": CNLabeledValue<CNSocialProfile>.localizedString(forLabel: profile.label ?? "")
                ]
            }
        } else {
            dict["socialProfiles"] = []
        }
        
        // Instant message addresses - safely access
        if contact.isKeyAvailable(CNContactInstantMessageAddressesKey) {
            dict["instantMessages"] = contact.instantMessageAddresses.map { im in
                let imAddress = im.value
                return [
                    "service": imAddress.service,
                    "username": imAddress.username,
                    "label": CNLabeledValue<CNInstantMessageAddress>.localizedString(forLabel: im.label ?? "")
                ]
            }
        } else {
            dict["instantMessages"] = []
        }
        
        // Dates (birthday and other events) - safely access
        var events: [[String: Any?]] = []
        
        // Birthday - safely access
        if contact.isKeyAvailable(CNContactBirthdayKey), let birthday = contact.birthday {
            var birthdayDict: [String: Any?] = [
                "label": "birthday",
                "month": birthday.month,
                "day": birthday.day
            ]
            if let year = birthday.year {
                birthdayDict["year"] = year
            }
            events.append(birthdayDict)
        }
        
        // Other dates - safely access
        if contact.isKeyAvailable(CNContactDatesKey) {
            for date in contact.dates {
                let dateComponents = date.value
                var dateDict: [String: Any?] = [
                    "label": CNLabeledValue<NSDateComponents>.localizedString(forLabel: date.label ?? ""),
                    "month": dateComponents.month,
                    "day": dateComponents.day
                ]
                if dateComponents.year != NSDateComponentUndefined {
                    dateDict["year"] = dateComponents.year
                }
                events.append(dateDict)
            }
        }
        
        dict["events"] = events
        
        // Note - safely access
        if contact.isKeyAvailable(CNContactNoteKey) {
            dict["note"] = contact.note
        } else {
            dict["note"] = ""
        }
        
        // Images - safely access
        if contact.isKeyAvailable(CNContactThumbnailImageDataKey), let thumbnailData = contact.thumbnailImageData {
            dict["thumbnail"] = FlutterStandardTypedData(bytes: thumbnailData)
        }
        
        if contact.isKeyAvailable(CNContactImageDataKey), let imageData = contact.imageData {
            dict["photo"] = FlutterStandardTypedData(bytes: imageData)
        }
        
        // Metadata
        dict["isStarred"] = false // iOS/macOS doesn't have starred concept like Android
        dict["propertiesFetched"] = true
        dict["thumbnailFetched"] = contact.isKeyAvailable(CNContactThumbnailImageDataKey) && contact.thumbnailImageData != nil
        dict["photoFetched"] = contact.isKeyAvailable(CNContactImageDataKey) && contact.imageData != nil
        
        return dict
    }
    
    func dictToContactMutableCopy(_ dict: [String: Any]) -> CNMutableContact {
        let mutableContact = CNMutableContact()
        
        // Basic information
        if let name = dict["name"] as? [String: Any] {
            mutableContact.givenName = name["givenName"] as? String ?? ""
            mutableContact.familyName = name["familyName"] as? String ?? ""
            mutableContact.middleName = name["middleName"] as? String ?? ""
            mutableContact.namePrefix = name["namePrefix"] as? String ?? ""
            mutableContact.nameSuffix = name["nameSuffix"] as? String ?? ""
            mutableContact.nickname = name["nickname"] as? String ?? ""
            mutableContact.phoneticGivenName = name["phoneticGivenName"] as? String ?? ""
            mutableContact.phoneticFamilyName = name["phoneticFamilyName"] as? String ?? ""
            mutableContact.phoneticMiddleName = name["phoneticMiddleName"] as? String ?? ""
        }
        
        // Organization
        if let organization = dict["organization"] as? [String: Any] {
            mutableContact.organizationName = organization["name"] as? String ?? ""
            mutableContact.jobTitle = organization["jobTitle"] as? String ?? ""
            mutableContact.departmentName = organization["department"] as? String ?? ""
        }
        
        // Phone numbers
        if let phones = dict["phones"] as? [[String: Any]] {
            mutableContact.phoneNumbers = phones.compactMap { phoneDict in
                guard let number = phoneDict["number"] as? String else { return nil }
                let label = phoneDict["label"] as? String ?? CNLabelPhoneNumberMain
                return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: number))
            }
        }
        
        // Email addresses
        if let emails = dict["emails"] as? [[String: Any]] {
            mutableContact.emailAddresses = emails.compactMap { emailDict in
                guard let email = emailDict["email"] as? String else { return nil }
                let label = emailDict["label"] as? String ?? CNLabelHome
                return CNLabeledValue(label: label, value: email as NSString)
            }
        }
        
        // Postal addresses
        if let addresses = dict["addresses"] as? [[String: Any]] {
            mutableContact.postalAddresses = addresses.compactMap { addressDict in
                let address = CNMutablePostalAddress()
                address.street = addressDict["street"] as? String ?? ""
                address.city = addressDict["city"] as? String ?? ""
                address.state = addressDict["state"] as? String ?? ""
                address.postalCode = addressDict["postalCode"] as? String ?? ""
                address.country = addressDict["country"] as? String ?? ""
                
                let label = addressDict["label"] as? String ?? CNLabelHome
                return CNLabeledValue(label: label, value: address)
            }
        }
        
        // URLs
        if let websites = dict["websites"] as? [[String: Any]] {
            mutableContact.urlAddresses = websites.compactMap { websiteDict in
                guard let url = websiteDict["url"] as? String else { return nil }
                let label = websiteDict["label"] as? String ?? CNLabelURLAddressHomePage
                return CNLabeledValue(label: label, value: url as NSString)
            }
        }
        
        // Note
        if let note = dict["note"] as? String {
            mutableContact.note = note
        }
        
        // Birthday
        if let events = dict["events"] as? [[String: Any]] {
            for event in events {
                if let label = event["label"] as? String, label == "birthday",
                   let month = event["month"] as? Int,
                   let day = event["day"] as? Int {
                    var dateComponents = DateComponents()
                    dateComponents.month = month
                    dateComponents.day = day
                    if let year = event["year"] as? Int {
                        dateComponents.year = year
                    }
                    mutableContact.birthday = dateComponents
                    break
                }
            }
        }
        
        return mutableContact
    }
}