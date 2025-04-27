import SwiftUI

struct PeriodPickerView: View {
    @ObservedObject var viewModel: StatisticViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([Period.week, .month, .year], id: \.self) { period in
                Button(action: {
                    viewModel.selectedPeriod = period
                }) {
                    Text(period.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(viewModel.selectedPeriod == period ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                }
            }
        }
    }
}