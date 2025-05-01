protocol RunningRecordAPIProtocol {
//    func getRunningRecords() async throws -> [RunningRecord]
    func getRunningRecords(page: Int, pageSize: Int) -> [RunningRecord]
}
