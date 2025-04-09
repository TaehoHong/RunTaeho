import SwiftUI

struct StatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                BPMView(bpm: 0)
                PaceView(minutes: 0, seconds: 0)
                TimeView(minutes: 0, seconds: 0)
            }
            .padding(.top, 20)
            
            Spacer()
            DistanceView(distance: 0.00)
            Spacer()
        }
    }
}