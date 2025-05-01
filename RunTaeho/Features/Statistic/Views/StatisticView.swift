import SwiftUI
import Charts

struct StatisticView: View {
    @StateObject private var viewModel = StatisticViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            PeriodPickerView(viewModel: viewModel)
            RunningChartView(viewModel: viewModel.chartViewModel)
            StatisticsSummaryView(viewModel: viewModel)
            RecordsListView(viewModel: viewModel)
        }
        .onAppear {
            if viewModel.records.isEmpty {
                viewModel.loadMoreRecords()
            }
        }
    }
}

struct StatsMainView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
