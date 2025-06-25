import Foundation

class RunningRecordViewModel: ObservableObject, Identifiable {
    let id: Int
    let distance: Double
    let distanceKm: Double
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
    
    init(from record: RunningRecord) {
        self.id = record.id
        self.distance = record.distance
        self.durationSec = record.durationSec
        self.startTimestamp = record.startTimestamp
        self.distanceKm = distance / 1000.0
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        return durationSec
    }
    
    var pace: TimeInterval {
        guard distanceKm > 0 else { return 0 }
        return durationSec / distanceKm // 초/km
    }
    
    var startDate: Date {
        return Date(timeIntervalSince1970: startTimestamp)
    }
    
    // MARK: - Formatted Strings
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH시 mm분"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.string(from: startDate)
    }
    
    var formattedDistance: String {
        return String(format: "%.2fkm", distanceKm)
    }
    
    var formattedPace: String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
