import Foundation

enum APIPath {
    enum Auth {
        static let googleOAuth = "api/v1/oauth/google"
        static let appleOAuth = "api/v1/oauth/apple"
    }
    
    enum User {
        static let base = "api/v1/users"
        static let me = "\(base)/me"
    }
    
    enum RunningRecord {
        static let base = "api/v1/running"
        static let search = base
        static let start = base
        static func end(_ id: Int) -> String {
            "\(base)/\(id)/end"
        }
        static func put(_ id: Int) -> String {
            "\(base)/\(id)"
        }
    }
    
    enum RunningRecordItem {
        static let base = "api/v1/running"
        
        
        static func save(_ id: Int) -> String {
            return "\(base)/\(id)/items"
        }
    }
    
    enum Point {
        static let base = "api/v1/users/points"
        static let add = "api/v1/users/points"
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
    
    enum Avatar {
        static let base = "api/v1/avatars"
        static func put(_ id: Int) -> String {
            return "\(base)/\(id)"
        }
    }
    
    enum Item {
        static let base = "api/v1/items"
        static let list = base
    }
    
    enum UserItem {
        static let base = "api/v1/user-items"
        static let post = base
    }
}
