import Foundation

enum APIPath {
    enum Auth {
        static let googleOAuth = "api/v1/oauth/google"
    }
    
    enum User {
        static let base = "api/v1/users"
        static let me = "\(base)/me"
    }
    
    enum RunningRecord {
        static let base = "api/v1/running"
        static let search = base
        static let start = base
    }
    
    enum Point {
        static let base = "api/v1/users/points"
        static let histories = "\(base)/histories"
    }
    
    enum Shoe {
        static let base = "api/v1/shoes"
        static let list = base
        static let create = base
        
        static func get(_ id: Int) -> String {
            return "\(base)/\(id)"
        }
        
        static func patch(_ id: Int) -> String {
            return "\(base)/\(id)"
        }
    }
}
