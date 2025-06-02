import Foundation

struct UserAuthData: Codable {
    let id: Int
    let email: String
    let nickname: String
    let accessToken: String
    let refreshToken: String
    let profileImageURL: String?
    let totalPoints: Int
    let level: Int
    
    // MARK: - Legacy Support
    var userId: Int { id }
    
    init(id: Int, email: String, nickname: String, accessToken: String, refreshToken: String, profileImageURL: String? = nil, totalPoints: Int = 0, level: Int = 1) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.profileImageURL = profileImageURL
        self.totalPoints = totalPoints
        self.level = level
    }
    
    // MARK: - Legacy Constructor
    init(userId: Int, accessToken: String, refreshToken: String) {
        self.id = userId
        self.email = "unknown@example.com"
        self.nickname = "사용자"
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.profileImageURL = nil
        self.totalPoints = 0
        self.level = 1
    }
}