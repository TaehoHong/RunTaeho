import AuthenticationServices
import Foundation

// MARK: - Apple 인증 전략
class AppleAuthenticationStrategy: NSObject, AuthenticationStrategy {
    
    static let shared = AppleAuthenticationStrategy()
    let authProvider = AuthProvider.APPLE
    
    // MARK: - Static Properties for SignInWithAppleButton result
    private var pendingAuthorization: ASAuthorization?
    private var pendingError: Error?
    
    // MARK: - Private Properties
    private var currentContinuation: CheckedContinuation<UserAuthData, Error>?
    
    // MARK: - AuthenticationStrategy Methods
    func signIn() async throws -> UserAuthData {
        // SignInWithAppleButton의 결과가 이미 있는지 확인
        if let authorization = self.pendingAuthorization {
            // 저장된 인증 결과 사용
            self.pendingAuthorization = nil
            return try await handleAuthorizationResult(authorization)
        }
        
        if let error = self.pendingError {
            // 저장된 에러 처리
            self.pendingError = nil
            throw error
        }
        
        // SignInWithAppleButton의 결과가 없으면 직접 인증 수행 (fallback)
        return try await withCheckedThrowingContinuation { continuation in
            currentContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Static Methods for SignInWithAppleButton integration
    /// SignInWithAppleButton의 성공 결과를 저장
    func setAppleSignInResult(_ authorization: ASAuthorization) {
        pendingAuthorization = authorization
        pendingError = nil
    }
    
    /// SignInWithAppleButton의 에러 결과를 저장
    func setAppleSignInError(_ error: Error) {
        pendingError = error
        pendingAuthorization = nil
    }
    
    
    // MARK: - Private Methods
    private func handleAuthorizationResult(_ authorization: ASAuthorization) async throws -> UserAuthData {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthenticationError.noUserProfile
        }
        
        
        guard let authorizationCode = appleIDCredential.authorizationCode,
              let authCode = String(data: authorizationCode, encoding: .utf8) else {
            throw AuthenticationError.noAuthCode
        }
        
        print("Apple Auth Code: \(authCode)")
        
        // 서버에서 토큰 획득
        let tokenDto = try await AuthenticationService.shared.getToken(provider: authProvider, code: authCode)
        
        // Apple에서 이메일과 이름 정보는 첫 로그인 시에만 제공됩니다
        let email = appleIDCredential.email ?? ""
        let fullName = appleIDCredential.fullName
        let nickname = [fullName?.familyName, fullName?.givenName]
            .compactMap { $0 }
            .joined(separator: " ")
            .isEmpty ? "Apple User" : [fullName?.familyName, fullName?.givenName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return UserAuthData(
            id: tokenDto.userId,
            email: email,
            nickname: nickname,
            accessToken: tokenDto.accessToken,
            refreshToken: tokenDto.refreshToken,
            profileImageURL: nil
        )
    }
    
    func signOut() throws {
        // Apple Sign-In은 명시적 로그아웃이 없음
        // 필요시 앱에서 자체적으로 상태 관리
        print("Apple Sign-Out: Apple does not provide explicit sign-out")
    }
    
    func isSignedIn() -> Bool {
        // Apple Sign-In 상태는 앱에서 자체적으로 관리해야 함
        // 실제 구현시에는 UserDefaults나 Keychain을 사용
        return false
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthenticationStrategy: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                let userData = try await handleAuthorizationResult(authorization)
                currentContinuation?.resume(returning: userData)
            } catch {
                currentContinuation?.resume(throwing: error)
            }
            currentContinuation = nil
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In Error: \(error.localizedDescription)")
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                currentContinuation?.resume(throwing: AuthenticationError.userCancelled)
            default:
                currentContinuation?.resume(throwing: AuthenticationError.signInFailed(error))
            }
        } else {
            currentContinuation?.resume(throwing: AuthenticationError.signInFailed(error))
        }
        
        currentContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleAuthenticationStrategy: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
