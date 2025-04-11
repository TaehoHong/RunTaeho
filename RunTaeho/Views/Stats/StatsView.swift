import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                BPMView(bpm: viewModel.statsManager.bpm)
                PaceView(minutes: viewModel.statsManager.pace.minutes, seconds: viewModel.statsManager.pace.seconds)
                TimeView(
                    hours: viewModel.elapsedTime.hours,
                    minutes: viewModel.elapsedTime.minutes,
                    seconds: viewModel.elapsedTime.seconds
                )
            }.padding(.top, 20)
            
            Spacer()
            DistanceView(distance: viewModel.distanceMeter / 1000.0)
            Spacer()
        }
    }
}
