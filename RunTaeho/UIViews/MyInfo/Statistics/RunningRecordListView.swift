import SwiftUI

struct RunningRecordListView: View {
    @ObservedObject var viewModel: StatisticViewModel

    var body: some View {
        return ScrollView {
            LazyVStack(spacing: 10) {
                let sortedRecords = viewModel.records.sorted(by: { $0.startTimestamp > $1.startTimestamp })
                ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                    RunningRecordRow(record: record)
                        .onAppear {
                            // 정렬된 리스트의 마지막 아이템이고, 로딩 중이 아닐 때만 더 로드
                            if viewModel.hasNextData {
                                Task {
                                    await viewModel.loadMoreRecords()
                                }
                            }
                        }
                }
            }
            .padding()
        }
    }
}
