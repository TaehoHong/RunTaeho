import Foundation

struct RequestConfiguration {
    var timeoutInterval: TimeInterval = 30
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    var allowsCellularAccess: Bool = true
    
    static let `default` = RequestConfiguration()
}
