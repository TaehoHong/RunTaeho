import Foundation

struct Pageable<T> {
    let data: [T]
    let size: Int
    let cursor: Int64
    let hasNext: Bool
}
