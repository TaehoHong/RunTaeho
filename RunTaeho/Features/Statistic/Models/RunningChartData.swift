import Foundation

struct RunningChartData: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let distance: Double
    let distanceKm: Double
    
    init(date: Date, distance: Double) {
        self.date = date
        self.distance = distance
        self.distanceKm = distance / 1000.0
    }
}
