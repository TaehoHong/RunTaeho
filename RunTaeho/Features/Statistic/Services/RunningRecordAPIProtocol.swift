import Foundation

protocol RunningRecordAPIProtocol {
    func getRunningRecords(cursor: Int64?, size: Int?, startDate: Date?, endDate: Date?) async throws -> Pageable<RunningRecord>
}
