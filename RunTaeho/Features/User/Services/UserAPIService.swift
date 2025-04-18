class UserAPIService {

    public let userAPIService = UserAPIService()
    
    private let httpClient = HTTPClient.shared

    private init() {

    }

    func getUserById(userId: Int, accessToken: String) async throws -> User {

        let urlString = GET_USER + "\(userId)"

        return try await withCheckedThrowingContinuation { continuation in
            httpClient.get(
                url: urlString,
                headers: ["Authorzation": "Bearer \(accessToken)"],
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
}
