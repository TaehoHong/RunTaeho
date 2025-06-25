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
                    .font(CustomFont.custom(size: 20))
                Spacer()
                
                Text(viewModel.formattedPace)
                    .font(CustomFont.custom(size: 20))
                Spacer()
                
                Text(viewModel.formattedDuration)
                    .font(CustomFont.custom(size: 20))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
