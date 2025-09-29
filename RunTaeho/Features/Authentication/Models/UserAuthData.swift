import Foundation

struct UserAuthData: Codable {
    let id: Int
    let email: String
    let nickname: String
    let accessToken: String
    let refreshToken: String
    let profileImageURL: String?
    
    // MARK: - Legacy Support
    var userId: Int { id }
    
    init(id: Int, email: String, nickname: String, accessToken: String, refreshToken: String, profileImageURL: String? = nil) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.profileImageURL = profileImageURL
    }
    
    // MARK: - Legacy Constructor
    init(userId: Int, accessToken: String, refreshToken: String) {
        self.id = userId
        self.email = "unknown@example.com"
        self.nickname = "사용자"
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.profileImageURL = nil
    }
}
