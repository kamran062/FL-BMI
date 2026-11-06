import SwiftUI

private let brand = Color(red: 0x22 / 255, green: 0xB5 / 255, blue: 0x73 / 255)

@main
struct BMIWatchApp: App {
    @StateObject private var model = WatchModel()

    var body: some Scene {
        WindowGroup { WorkoutView().environmentObject(model) }
    }
}

/// Apple Watch companion (ROADMAP 5.4): current set, Done, rest timer,
/// heart rate. Mirrors the Wear OS app.
struct WorkoutView: View {
    @EnvironmentObject var model: WatchModel
    @State private var wasResting = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { context in
            let s = model.state
            let rest = s.restLeft(now: context.date)
            VStack(spacing: 4) {
                if !s.active {
                    Text("Start a workout on your iPhone").multilineTextAlignment(.center)
                } else if s.allDone {
                    Text("All sets done!\nFinish on your iPhone.").multilineTextAlignment(.center)
                } else {
                    Text(s.exercise).font(.headline).lineLimit(2).multilineTextAlignment(.center)
                    Text("Set \(s.setNumber) of \(s.setsTotal)").font(.footnote)
                    Text(s.target).font(.title3.bold())
                    if rest > 0 {
                        Text("Rest \(formatClock(rest))").foregroundStyle(brand)
                    }
                    Button("Done") { model.done() }
                        .tint(brand)
                        .buttonStyle(.borderedProminent)
                }
                if s.active && model.heartRate > 0 {
                    Label("\(model.heartRate) bpm", systemImage: "heart.fill")
                        .font(.footnote).foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            .onChange(of: rest > 0) { _, resting in
                if wasResting && !resting { model.restOver() }
                wasResting = resting
            }
        }
    }
}
