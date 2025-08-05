import SwiftUI

struct RunningPausedView: View {
    @ObservedObject var viewModel: RunningViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        VStack(spacing: 25) {
            // Running Statistics (showing current progress)
            StatsView(viewModel: viewModel)
            
            // Control Buttons
            HStack(spacing: 40) {
                Spacer()
                
                // Stop Button
                StopButton { 
                    viewModel.stopRunning()
                }
                
                Spacer()
                
                // Resume Button
                PlayButton { 
                    viewModel.resumeRunning()
                }
                
                Spacer()
            }
        }
        .frame(width: width, height: height * 0.5)
        .position(x: width / 2, y: height * 0.75)
    }
}
