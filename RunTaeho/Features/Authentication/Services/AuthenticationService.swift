import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() { }

    func getToken(provider: AuthProvider, code: String) async throws -> UserAuthData {
        print("Getting token for \(provider.displayName) with code: \(code)")
        
        return try await withCheckedThrowingContinuation { continuation in
            HTTPClient.shared.get(
                url: "http://localhost:8080/api/v1/oauth/google",
                requestParam: RequestParam(params: ["code": code]),
                responseType: UserAuthData.self
            ) { result in
                switch result {
                case .success(let authData):
                    print("Token received for \(provider.displayName): \(authData)")
                    continuation.resume(returning: authData)
                case .failure(let error):
                    print("Error occurred for \(provider.displayName): \(error)")
                    continuation.resume(throwing: AuthenticationError.networkError(error))
                }
            }
        }
    }
}
