import Foundation

/// Mirror of WearState in lib/features/train/wear/wear_bridge.dart.
struct WorkoutState: Equatable {
    var active = false
    var exercise = ""
    var setNumber = 0
    var setsTotal = 0
    var weightKg = 0.0
    var reps = 0
    var restEndsAtMs: Double = 0
    var allDone = false

    static let idle = WorkoutState()

    /// Never fails: a bad message shows the idle screen.
    static func parse(_ json: String?) -> WorkoutState {
        guard let data = json?.data(using: .utf8),
              let o = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return .idle }
        var s = WorkoutState()
        s.active = o["active"] as? Bool ?? false
        s.exercise = o["exercise"] as? String ?? ""
        s.setNumber = (o["setNumber"] as? NSNumber)?.intValue ?? 0
        s.setsTotal = (o["setsTotal"] as? NSNumber)?.intValue ?? 0
        s.weightKg = (o["weightKg"] as? NSNumber)?.doubleValue ?? 0
        s.reps = (o["reps"] as? NSNumber)?.intValue ?? 0
        s.restEndsAtMs = (o["restEndsAt"] as? NSNumber)?.doubleValue ?? 0
        s.allDone = o["allDone"] as? Bool ?? false
        return s
    }

    /// Seconds of rest left (rounded up), 0 when none.
    func restLeft(now: Date) -> Int {
        let left = restEndsAtMs / 1000 - now.timeIntervalSince1970
        return left <= 0 ? 0 : Int(left.rounded(.up))
    }

    /// "60 kg × 8", "62.5 kg × 8", or "× 12" for bodyweight sets.
    var target: String {
        guard weightKg > 0 else { return "× \(reps)" }
        let kg = weightKg == weightKg.rounded()
            ? String(Int(weightKg))
            : String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), weightKg)
        return "\(kg) kg × \(reps)"
    }
}

func formatClock(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}
