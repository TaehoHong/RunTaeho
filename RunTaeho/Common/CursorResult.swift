import Foundation

struct CursorResult<T: Codable>: Codable {
    let content: [T]
    let cursor: Int?
    let hasNext: Bool
}
