import Foundation

// MARK: - 인증 제공자 타입
enum AuthProvider: String, Codable, CaseIterable {
    case google = "google"
    case apple = "apple"
    
    var displayName: String {
        switch self {
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        }
    }
    
    var iconName: String {
        switch self {
        case .google:
            return "google_icon"
        case .apple:
            return "apple.logo"
        }
    }
}

// MARK: - 인증 제공자 타입 (Strategy Pattern용)
typealias AuthProviderType = AuthProvider
