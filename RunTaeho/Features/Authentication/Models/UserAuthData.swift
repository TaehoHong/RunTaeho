import Foundation

struct UserAuthData: Decodable {
    let userId:Int
    let accessToken:String
    let refreshToken:String
    
    init(userId: Int, accessToken: String, refreshToken: String) {
        self.userId = userId
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}