import SwiftUI

struct CadenceView: View {
    let cadence: Int
    let isFromWatch: Bool
    
    private var cadenceText: String {
        String(format: "%03d", cadence)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                Text("SPM")
                    .font(CustomFont.stats())
                if isFromWatch {
                    Image(systemName: "applewatch")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            Text(cadenceText)
                .font(CustomFont.stats())
        }
        .frame(width: 105, height: 45)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}