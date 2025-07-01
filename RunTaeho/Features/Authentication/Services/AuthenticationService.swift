import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() { }

    func getToken(provider: AuthProvider, code: String) async throws -> TokenDto {
        print("Getting token for \(provider.displayName) with code: \(code)")
        
        return try await withCheckedThrowingContinuation { continuation in
            HTTPClient.shared.get(
                urlPath: APIPath.Auth.googleOAuth,
                requestParam: RequestParam(params: ["code": code]),
                responseType: TokenDto.self
            ) { result in
                switch result {
                case .success(let tokenDto):
                    print("Token received for \(provider.displayName): \(tokenDto)")
                    continuation.resume(returning: tokenDto)
                case .failure(let error):
                    print("Error occurred for \(provider.displayName): \(error)")
                    continuation.resume(throwing: AuthenticationError.networkError(error))
                }
            }
        }
    }
}
