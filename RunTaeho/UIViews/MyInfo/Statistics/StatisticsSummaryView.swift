import SwiftUI

struct StatisticsSummaryView: View {
    @ObservedObject var viewModel: StatisticViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(viewModel.statistics.runCount) 러닝")
                .font(CustomFont.custom(size: 20))
            Spacer()
            
            VStack(spacing: 10) {
                Text("총 거리")
                    .font(CustomFont.custom(size: 20))
                Text(String(format: "%.2fkm", viewModel.statistics.totalDistance))
                    .font(CustomFont.custom(size: 20))
            }
            Spacer()
            VStack {
                Text("총 시간")
                    .font(CustomFont.custom(size: 20))
                Text(formatDuration(viewModel.statistics.totalDuration))
                    .font(CustomFont.custom(size: 20))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
