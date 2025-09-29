class UserAPIService {

    public static let shared = UserAPIService()
    
    private let httpClient = HTTPClient.shared

    private init() {

    }

    func getUserById(userId: Int, accessToken: String) async throws -> User {

        let urlString = APIPath.User.base + "/\(userId)"

        return try await withCheckedThrowingContinuation { continuation in
            httpClient.get(
                urlPath: urlString,
                headers: ["Authorization": "Bearer \(accessToken)"],
                responseType: User.self
            ) { result in
                switch result {
                    case .success(let user):
                        print("UserInfo received: \(user)")
                        continuation.resume(returning: user)
                    case .failure(let error):
                        print("Error occurred: \(error)")
                        continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUserDataDto(_ accessToken: String) async throws -> UserDataDto {
        return try await withCheckedThrowingContinuation { continuation in
            httpClient.get(
                urlPath: APIPath.User.me,
                headers: ["Authorization": "Bearer \(accessToken)"],
                responseType: UserDataDto.self
            ) { result in
                switch result {
                case .success(let user):
                    print("UserInfo received: \(user)")
                    continuation.resume(returning: user)
                case .failure(let error):
                    print("Error occurred: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
