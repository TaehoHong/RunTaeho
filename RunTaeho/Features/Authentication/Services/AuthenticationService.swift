class AuthenticationService {
    static let shared = AuthenticationService()
    private init() { }

    func getToken(authType: AuthType, code: String) async throws -> UserAuthData {
        print("code: \(code)")
        
        return try await withCheckedThrowingContinuation { continuation in
            HTTPClient.shared.get(
                url: "http://localhost:8080/api/v1/oauth/google",
                requestParam: RequestParam(params: ["code": code]),
                responseType: UserAuthData.self
            ) { result in
                switch result {
                case .success(let authData):
                    print("Token received: \(authData)")
                    continuation.resume(returning: authData)
                case .failure(let error):
                    print("Error occurred: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


enum AuthType {
    case Google
    case Apple
}
