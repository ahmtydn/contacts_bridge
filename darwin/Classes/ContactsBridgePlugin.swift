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
public class ContactsBridgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.ahmtydn.contacts_bridge", binaryMessenger: registrar.messenger)
    let instance = ContactsBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      #if os(macOS)
        result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
      #else
        result("iOS " + UIDevice.current.systemVersion)
      #endif
      
    case "requestPermission":
      handleRequestPermission(call: call, result: result)
      
    case "getPermissionStatus":
      handleGetPermissionStatus(result: result)
      
    case "getAllContacts":
      handleGetAllContacts(call: call, result: result)
      
    case "getContact":
      handleGetContact(call: call, result: result)
      
    case "searchContacts":
      handleSearchContacts(call: call, result: result)
      
    case "createContact":
      handleCreateContact(call: call, result: result)
      
    case "updateContact":
      handleUpdateContact(call: call, result: result)
      
    case "deleteContact":
      handleDeleteContact(call: call, result: result)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
