import SwiftUI

struct RunningRecordListView: View {
    @ObservedObject var viewModel: StatisticViewModel

    var body: some View {
        return ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.records.sorted(by: { $0.date > $1.date })) { record in
                    RunningRecordRow(record: record)
                        .onAppear {
                            if record.id == viewModel.records.last?.id {
                                Task {
                                    try await viewModel.loadMoreRecords()
                                }
                            }
                        }
                }
            }
            .padding()
        }
    }
}
