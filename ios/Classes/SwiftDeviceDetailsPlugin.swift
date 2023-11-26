import Flutter
import UIKit
import CoreTelephony

public class SwiftDeviceDetailsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "device_details_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftDeviceDetailsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        var iOSDeviceInfo: [String: Any] = [:]
        
        if(call.method.elementsEqual("getiOSInfo")) {
            iOSDeviceInfo["appName"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
            iOSDeviceInfo["packageName"] = Bundle.main.bundleIdentifier
            iOSDeviceInfo["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            iOSDeviceInfo["buildNumber"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            iOSDeviceInfo["flutterAppVersion"] = SwiftDeviceDetailsPlugin.getFlutterAppVersion()
            iOSDeviceInfo["osVersion"] = String(UIDevice.current.systemVersion)
            iOSDeviceInfo["totalInternalStorage"] = UIDevice.current.totalDiskSpaceInGB
            iOSDeviceInfo["freeInternalStorage"] = UIDevice.current.freeDiskSpaceInGB
            iOSDeviceInfo["mobileNetwork"] = SwiftDeviceDetailsPlugin.getCarrierName()
            iOSDeviceInfo["totalRamSize"] = humanReadableByteCount(bytes: Int(ProcessInfo.processInfo.physicalMemory))
            iOSDeviceInfo["freeRamSize"] = "0"
            iOSDeviceInfo["screenSize"] = SwiftDeviceDetailsPlugin.getDisplaySize()
            iOSDeviceInfo["dateAndTime"] = SwiftDeviceDetailsPlugin.getCurrentDateTime()
            iOSDeviceInfo["manufacturer"] = "Apple"
            iOSDeviceInfo["deviceId"] = UIDevice.current.identifierForVendor?.uuidString
        }
        result(iOSDeviceInfo)
    }
    
    func humanReadableByteCount(bytes: Int) -> String {
        if (bytes < 1000) { return "\(bytes) B" }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit).replacingOccurrences(of: ".0", with: "")
        }
    }
    
    static func getCarrierName() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        let carrierName = carrier?.carrierName
        return carrierName
    }
    
    static func getDisplaySize() -> String? {
        let scale = UIScreen.main.scale
        let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163);
        let width = UIScreen.main.bounds.size.width * scale
        let height = UIScreen.main.bounds.size.height * scale
        let horizontal = width / ppi, vertical = height / ppi;
        let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
        let screenSize = String(format: "%0.1f", diagonal)
        return screenSize
    }
    
    static func getCurrentDateTime() -> String? {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        return dateString
    }
    
    static func getFlutterAppVersion() -> String? {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        var flutterAppVersion = ""
        if buildNumber == "" {
            flutterAppVersion = versionNumber
        } else {
            flutterAppVersion =  versionNumber + "+" + buildNumber
        }
        return flutterAppVersion
    }
}

extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
    
}

