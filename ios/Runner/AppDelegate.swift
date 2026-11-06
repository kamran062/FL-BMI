import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
  /// Apple Watch companion (ROADMAP 5.4): same channel as the Wear OS
  /// bridge, so lib/features/train/wear/wear_bridge.dart works unchanged.
  private var wearChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Health, location, cycle and photo data must stay on this device
    // (privacy policy): mark their folders "exclude from iCloud backup".
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "bmi_health/backup", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        guard call.method == "exclude", let path = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
          try FileManager.default.createDirectory(
            at: url, withIntermediateDirectories: true)
          try url.setResourceValues(values)
          result(true)
        } catch {
          result(FlutterError(code: "exclude_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
    if let controller = window?.rootViewController as? FlutterViewController {
      let wear = FlutterMethodChannel(name: "bmi_health/wear", binaryMessenger: controller.binaryMessenger)
      wear.setMethodCallHandler { call, result in
        guard call.method == "sync", let json = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        let s = WCSession.default
        guard WCSession.isSupported(), s.activationState == .activated,
              s.isPaired, s.isWatchAppInstalled else {
          result(false) // no watch: nothing to do
          return
        }
        do {
          // The latest state wins; the watch reads it even after a restart.
          try s.updateApplicationContext(["json": json, "t": Date().timeIntervalSince1970])
          result(true)
        } catch {
          result(false)
        }
      }
      wearChannel = wear
    }
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: Watch → phone

  private func handleWatch(_ message: [String: Any]) {
    DispatchQueue.main.async {
      switch message["event"] as? String {
      case "setDone": self.wearChannel?.invokeMethod("setDone", arguments: nil)
      case "heartRate":
        if let bpm = (message["bpm"] as? NSNumber)?.intValue {
          self.wearChannel?.invokeMethod("heartRate", arguments: bpm)
        }
      default: break
      }
    }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    handleWatch(message)
  }

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    handleWatch(userInfo)
  }

  func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
