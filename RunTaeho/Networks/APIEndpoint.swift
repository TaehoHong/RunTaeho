import Foundation

extension HTTPClient {
    enum APIEndpoint {
        case users(id: Int)
        case user
        case posts
        case post(id: Int)
        case comments(postId: Int)
        case login
        case logout
        case register
        case custom(path: String)
        
        var path: String {
            switch self {
            case .users(let id):
                return "/users/\(id)"
            case .user:
                return "/user"
            case .posts:
                return "/posts"
            case .post(let id):
                return "/posts/\(id)"
            case .comments(let postId):
                return "/posts/\(postId)/comments"
            case .login:
                return "/auth/login"
            case .logout:
                return "/auth/logout"
            case .register:
                return "/auth/register"
            case .custom(let path):
                return path
            }
        }
    }
}
