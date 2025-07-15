import Foundation

struct CursorResult<T: Codable>: Codable {
    let content: [T]
    let cursor: Int?
    let hasNext: Bool
    
    func of<R>(_ mapper: (T) -> R) -> CursorResult<R> {
        return CursorResult<R>(
            content: content.map(mapper),
            cursor: cursor,
            hasNext: hasNext
        )
    }
}
