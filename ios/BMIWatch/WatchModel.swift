import Foundation
import HealthKit
import WatchConnectivity
import WatchKit

/// Phone link (WatchConnectivity) and heart rate (HealthKit workout session).
final class WatchModel: NSObject, ObservableObject, WCSessionDelegate,
                        HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    @Published var state = WorkoutState.idle
    @Published var heartRate = 0

    private let health = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var lastHrSent = Date.distantPast

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        #if DEBUG
        // Preview a state without a paired iPhone:
        // simctl launch … -debugState '<json>'
        // Read the raw argument: UserDefaults would parse "{…}" as a plist.
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-debugState"), i + 1 < args.count {
            state = WorkoutState.parse(args[i + 1])
        }
        #endif
    }

    // MARK: Phone → watch

    func session(_ s: WCSession, activationDidCompleteWith st: WCSessionActivationState, error: Error?) {
        // The last state the phone sent, even if we were closed at the time.
        // Empty means the phone hasn't sent anything yet: keep what we show.
        if !s.receivedApplicationContext.isEmpty { apply(s.receivedApplicationContext) }
    }

    func session(_ s: WCSession, didReceiveApplicationContext context: [String: Any]) {
        apply(context)
    }

    private func apply(_ context: [String: Any]) {
        let next = WorkoutState.parse(context["json"] as? String)
        DispatchQueue.main.async {
            self.state = next
            next.active ? self.startHeartRate() : self.stopHeartRate()
        }
    }

    // MARK: Watch → phone

    func done() {
        WKInterfaceDevice.current().play(.click)
        send(["event": "setDone"])
    }

    private func send(_ message: [String: Any]) {
        let s = WCSession.default
        guard s.activationState == .activated else { return }
        if s.isReachable {
            s.sendMessage(message, replyHandler: nil) { _ in s.transferUserInfo(message) }
        } else {
            // Delivered when the phone app runs again.
            s.transferUserInfo(message)
        }
    }

    func restOver() {
        WKInterfaceDevice.current().play(.notification)
    }

    // MARK: Heart rate (only while a workout is active)

    private func startHeartRate() {
        guard session == nil, HKHealthStore.isHealthDataAvailable() else { return }
        let hr = HKQuantityType(.heartRate)
        // A workout session keeps the sensor running; it is discarded at the
        // end, so nothing is written to Apple Health.
        health.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [hr]) { ok, _ in
            guard ok else { return }
            DispatchQueue.main.async { self.beginSession() }
        }
    }

    private func beginSession() {
        guard session == nil, state.active else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor
        do {
            let s = try HKWorkoutSession(healthStore: health, configuration: config)
            let b = s.associatedWorkoutBuilder()
            b.dataSource = HKLiveWorkoutDataSource(healthStore: health, workoutConfiguration: config)
            s.delegate = self
            b.delegate = self
            session = s
            builder = b
            s.startActivity(with: Date())
            b.beginCollection(withStart: Date()) { _, _ in }
        } catch {
            session = nil
        }
    }

    private func stopHeartRate() {
        guard let s = session else { return }
        s.end()
        builder?.discardWorkout()
        session = nil
        builder = nil
        heartRate = 0
    }

    func workoutBuilder(_ b: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        let hr = HKQuantityType(.heartRate)
        guard types.contains(hr),
              let q = b.statistics(for: hr)?.mostRecentQuantity() else { return }
        let bpm = Int(q.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        DispatchQueue.main.async {
            self.heartRate = bpm
            if Date().timeIntervalSince(self.lastHrSent) >= 5 { // at most every 5 s
                self.lastHrSent = Date()
                self.send(["event": "heartRate", "bpm": bpm])
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ b: HKLiveWorkoutBuilder) {}
    func workoutSession(_ s: HKWorkoutSession, didChangeTo to: HKWorkoutSessionState,
                        from: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ s: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async { self.session = nil; self.builder = nil }
    }
}
