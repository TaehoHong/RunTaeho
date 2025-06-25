import SwiftUI

struct RunningRecordRow: View {
    
    @ObservedObject var viewModel: RunningRecordViewModel
    
    init(record: RunningRecord) {
        self.viewModel = RunningRecordViewModel(from: record)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text(viewModel.formattedDistance)
                Spacer()
                Text(viewModel.formattedPace)
                Spacer()
                Text(viewModel.formattedDuration)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
