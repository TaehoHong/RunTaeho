import Foundation

// MARK: - 연결 계정 모델
struct UserAccount: Codable, Identifiable {
    let id: Int
    let provider: AuthProvider
    let isConnected: Bool
    let connectedAt: Date?
    let email: String?
    
    init(id: Int = 0, provider: AuthProvider, isConnected: Bool = false, connectedAt: Date? = nil, email: String? = nil) {
        self.id = id
        self.provider = provider
        self.isConnected = isConnected
        self.connectedAt = connectedAt
        self.email = email
    }
    
    
    func disconnect() -> UserAccount {
        UserAccount(
            id: self.id,
            provider: self.provider,
            isConnected: false,
            connectedAt: self.connectedAt,
            email: self.email
        )
    }
}

// MARK: - 연결 계정 상태
enum AccountConnectionStatus {
    case connected
    case none
    
    var buttonColor: String {
        switch self {
        case .none:
            return "#d9d9d9"
        case .connected:
            return "#7ae87a"
        }
    }
}
