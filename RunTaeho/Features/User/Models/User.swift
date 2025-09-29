import Foundation

// MARK: - User Model
struct User: Codable {
    let id: Int
    var nickname: String
    var userAccounts: [UserAccount]
    var profileImageURL: String?
    
    var level: Int
    var createdAt: Date
    var lastLoginAt: Date?
    
    // MARK: - Computed Properties
    var displayName: String {
        return nickname.isEmpty ? "사용자" : nickname
    }
    
    // MARK: - Initialization
    init(id: Int, nickname: String, userAccounts: [UserAccount] = [], profileImageURL: String? = nil, level: Int = 1, createdAt: Date = Date(), lastLoginAt: Date? = nil) {
        self.id = id
        self.nickname = nickname
        self.userAccounts = userAccounts
        self.profileImageURL = profileImageURL
        self.level = level
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    // MARK: - Codable Implementation
    // struct는 자동으로 Codable을 구현하므로 CodingKeys와 init/encode 메서드 제거 가능
    
    // MARK: - Methods
    // User를 struct로 변경했으므로 mutating 키워드 추가
    mutating func updateLastLogin() {
        lastLoginAt = Date()
    }

    
    mutating func updateProfile(nickname: String? = nil, profileImageURL: String? = nil) {
        if let nickname = nickname {
            self.nickname = nickname
        }
        if let profileImageURL = profileImageURL {
            self.profileImageURL = profileImageURL
        }
    }
    
    mutating func addUserAccount(_ account: UserAccount) {
        // 동일한 provider의 계정이 이미 있는지 확인
        if !userAccounts.contains(where: { $0.provider == account.provider }) {
            userAccounts.append(account)
        }
    }
    
    mutating func removeUserAccount(provider: AuthProvider) {
        userAccounts.removeAll { $0.provider == provider }
    }
}
