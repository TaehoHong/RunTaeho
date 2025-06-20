import GoogleSignIn
import GoogleSignInSwift
import UIKit

// MARK: - Google 인증 전략
class GoogleAuthenticationStrategy: AuthenticationStrategy {
    
    let authProvider = AuthProvider.GOOGLE
    
    // MARK: - Private Properties
    private let gidSignInInstance = GIDSignIn.sharedInstance
    
    // MARK: - Initialization
    init() {
        configureGoogleSignIn()
    }
    
    // MARK: - AuthenticationStrategy Methods
    func signIn() async throws -> UserAuthData {
        guard let presentingViewController = await getPresentingViewController() else {
            throw AuthenticationError.noPresentingViewController
        }
        
        do {
            let result = try await gidSignInInstance.signIn(withPresenting: presentingViewController)
            
            guard let profile = result.user.profile else {
                throw AuthenticationError.noUserProfile
            }
            
            let authCode = result.serverAuthCode ?? ""
            guard !authCode.isEmpty else {
                throw AuthenticationError.noAuthCode
            }
            
            print("Google Auth Code: \(authCode)")
            print("Google ID Token: \(result.user.idToken?.tokenString ?? "No ID Token")")
            
            // 서버에서 토큰 획득
            let tokenDto = try await AuthenticationService.shared.getToken(provider: authProvider, code: authCode)
            
            return UserAuthData(
                id: tokenDto.userId,
                email: profile.email,
                nickname: profile.name,
                accessToken: tokenDto.accessToken,
                refreshToken: tokenDto.refreshToken,
                profileImageURL: nil
            )
            
        } catch let error as AuthenticationError {
            throw error
        } catch {
            print("Google Sign-In Error: \(error.localizedDescription)")
            throw AuthenticationError.signInFailed(error)
        }
    }
    
    func signOut() throws {
        gidSignInInstance.signOut()
    }
    
    func isSignedIn() -> Bool {
        return gidSignInInstance.hasPreviousSignIn()
    }
    
    // MARK: - Private Methods
    private func configureGoogleSignIn() {
        gidSignInInstance.configuration = GIDConfiguration(
            clientID: "620303212609-581f7f3bgj104gtaermbtjqqf8u6khb8.apps.googleusercontent.com",
            serverClientID: "620303212609-tqerha7lmhgr719hd8qsd09kualf72l9.apps.googleusercontent.com"
        )
    }
    
    @MainActor
    private func getPresentingViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}
