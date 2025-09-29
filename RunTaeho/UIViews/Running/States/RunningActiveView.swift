import SwiftUI

struct RunningActiveView: View {
    @ObservedObject var viewModel: RunningViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        VStack(spacing: 25) {
            // Running Statistics
            StatsView(viewModel: viewModel)
            
            // Pause Button
            PauseButton {
                viewModel.pauseRunning()
            }
            .padding(.bottom, 0)
        }
        .frame(width: width, height: height * 0.5)
        .position(x: width / 2, y: height * 0.75)
    }
}
