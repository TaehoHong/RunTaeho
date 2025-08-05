import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() { }

    func getToken(provider: AuthProvider, code: String) async throws -> TokenDto {
        print("Getting token for \(provider.displayName) with code: \(code)")
        
        let urlPath = getOAuthPath(for: provider)
        
        return try await withCheckedThrowingContinuation { continuation in
            HTTPClient.shared.get(
                urlPath: urlPath,
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
    
    private func getOAuthPath(for provider: AuthProvider) -> String {
        switch provider {
        case .GOOGLE:
            return APIPath.Auth.googleOAuth
        case .APPLE:
            return APIPath.Auth.appleOAuth
        }
    }
}
