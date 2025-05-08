import Foundation

class RunningRecordListViewModel: ObservableObject {

    @Published var runningRecords: [RunningRecord]


    init(runningRecords: [RunningRecord]) {
        self.runningRecords = runningRecords
    }
}
