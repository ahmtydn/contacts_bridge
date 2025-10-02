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
    
    // MARK: - Permission Management
    
    func handleRequestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInteractive).async {
            CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(
                            code: "PERMISSION_ERROR",
                            message: "Failed to request permission",
                            details: error.localizedDescription
                        ))
                        return
                    }
                    result(granted ? "granted" : "denied")
                }
            }
        }
    }
    
    func handleGetPermissionStatus(result: @escaping FlutterResult) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            result("notDetermined")
        case .restricted:
            result("restricted")
        case .denied:
            result("denied")
        case .authorized:
            result("authorized")
        case .limited:
            result("limited")
        @unknown default:
            result("unknown")
        }
    }
    
    // MARK: - Contact Operations
    
    func handleGetAllContacts(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let withProperties = args["withProperties"] as? Bool ?? false
        let withThumbnail = args["withThumbnail"] as? Bool ?? false
        let withPhoto = args["withPhoto"] as? Bool ?? false
        let sorted = args["sorted"] as? Bool ?? true
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let contacts = try self.getAllContacts(
                    withProperties: withProperties,
                    withThumbnail: withThumbnail,
                    withPhoto: withPhoto,
                    sorted: sorted
                )
                let contactsData = contacts.map { self.contactToDict($0) }
                DispatchQueue.main.async {
                    result(contactsData)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "FETCH_ERROR",
                        message: "Failed to fetch contacts",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
    
    func handleGetContact(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let contactId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Contact ID is required", details: nil))
            return
        }
        
        let withProperties = args["withProperties"] as? Bool ?? true
        let withThumbnail = args["withThumbnail"] as? Bool ?? false
        let withPhoto = args["withPhoto"] as? Bool ?? false
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                if let contact = try self.getContact(
                    id: contactId,
                    withProperties: withProperties,
                    withThumbnail: withThumbnail,
                    withPhoto: withPhoto
                ) {
                    let contactData = self.contactToDict(contact)
                    DispatchQueue.main.async {
                        result(contactData)
                    }
                } else {
                    DispatchQueue.main.async {
                        result(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "FETCH_ERROR",
                        message: "Failed to fetch contact",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
    
    func handleSearchContacts(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let query = args["query"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Search query is required", details: nil))
            return
        }
        
        let withProperties = args["withProperties"] as? Bool ?? false
        let sorted = args["sorted"] as? Bool ?? true
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let contacts = try self.searchContacts(
                    query: query,
                    withProperties: withProperties,
                    sorted: sorted
                )
                let contactsData = contacts.map { self.contactToDict($0) }
                DispatchQueue.main.async {
                    result(contactsData)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "SEARCH_ERROR",
                        message: "Failed to search contacts",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
    
    func handleCreateContact(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let contactData = args["contact"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Contact data is required", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let contact = try self.createContact(from: contactData)
                let createdContactData = self.contactToDict(contact)
                DispatchQueue.main.async {
                    result(createdContactData)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "CREATE_ERROR",
                        message: "Failed to create contact",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
    
    func handleUpdateContact(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let contactData = args["contact"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Contact data is required", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let contact = try self.updateContact(from: contactData)
                let updatedContactData = self.contactToDict(contact)
                DispatchQueue.main.async {
                    result(updatedContactData)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "UPDATE_ERROR",
                        message: "Failed to update contact",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
    
    func handleDeleteContact(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let contactId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Contact ID is required", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try self.deleteContact(id: contactId)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "DELETE_ERROR",
                        message: "Failed to delete contact",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
}