import Foundation

protocol RunningRecordAPIProtocol {
    func getRunningRecords(cursor: Int?, size: Int?, startDate: Date?, endDate: Date?) async throws -> CursorResult<RunningRecord>
}
