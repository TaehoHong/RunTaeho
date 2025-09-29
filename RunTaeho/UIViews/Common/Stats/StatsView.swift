import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                BPMView(
                    bpm: viewModel.currentMetrics.heartRate,
                    isFromWatch: viewModel.isWatchConnected && viewModel.currentMetrics.heartRate > 0
                )
                
                TimeView(
                    hours: viewModel.elapsedTime.hours,
                    minutes: viewModel.elapsedTime.minutes,
                    seconds: viewModel.elapsedTime.seconds
                )
                
                PaceView(
                    minutes: viewModel.currentMetrics.pace.minutes, 
                    seconds: viewModel.currentMetrics.pace.seconds
                )

            }.padding(.top, 20)
            
            HStack(spacing: 15) {
                
                // 활성 데이터 소스 표시
                ForEach(Array(viewModel.activeDataSources), id: \.self) { source in
                    DataSourceIndicatorView(sourceType: source)
                }
            }
            
            Spacer()
            DistanceView(distance: viewModel.distanceMeter / 1000.0)
            Spacer()
        }
    }
}
