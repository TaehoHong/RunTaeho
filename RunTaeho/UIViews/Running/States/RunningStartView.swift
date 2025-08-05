import SwiftUI

struct RunningStartView: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            StartButton {
                viewModel.startRunning()
            }
        }
    }
}
