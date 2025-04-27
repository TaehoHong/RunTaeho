import SwiftUI

struct RunningRecordRow: View {
    let record: RunningRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDate(record.date))
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text(String(format: "%.1fkm", record.distance))
                Spacer()
                Text(formatPace(record.pace))
                Spacer()
                Text(formatDuration(record.duration))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH시 mm분"
        return formatter.string(from: date)
    }
    
    private func formatPace(_ pace: TimeInterval) -> String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}