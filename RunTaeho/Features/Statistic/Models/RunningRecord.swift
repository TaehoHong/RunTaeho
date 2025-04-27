import Foundation

struct RunningRecord: Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double
    let pace: TimeInterval
    let duration: TimeInterval
}