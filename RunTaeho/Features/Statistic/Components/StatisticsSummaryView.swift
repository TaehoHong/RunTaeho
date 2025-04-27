import SwiftUI

struct StatisticsSummaryView: View {
    @ObservedObject var viewModel: StatisticViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(viewModel.statistics.runCount) 러닝")
                .font(.headline)
            
            HStack {
                Text("총 거리")
                Spacer()
                Text(String(format: "%.1fkm", viewModel.statistics.totalDistance))
            }
            
            HStack {
                Text("총 시간")
                Spacer()
                Text(formatDuration(viewModel.statistics.totalDuration))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}