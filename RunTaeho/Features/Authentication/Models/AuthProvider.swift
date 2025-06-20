import Foundation

// MARK: - 인증 제공자 타입
enum AuthProvider: String, Codable, CaseIterable {
    case GOOGLE = "GOOGLE"
    case APPLE = "APPLE"
    
    var displayName: String {
        switch self {
        case .GOOGLE:
            return "Google"
        case .APPLE:
            return "Apple"
        }
    }
    
    var iconName: String {
        switch self {
        case .GOOGLE:
            return "google_icon"
        case .APPLE:
            return "apple.logo"
        }
    }
}
