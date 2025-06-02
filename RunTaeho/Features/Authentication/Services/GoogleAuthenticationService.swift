import GoogleSignIn
import GoogleSignInSwift

class GoogleAuthenticationService: AuthenticationProtocol {
    static let shared = GoogleAuthenticationService()
    private let gidSignInInstance = GIDSignIn.sharedInstance

    private init() {
        gidSignInInstance.configuration = GIDConfiguration(
            clientID: "620303212609-581f7f3bgj104gtaermbtjqqf8u6khb8.apps.googleusercontent.com",
            serverClientID: "620303212609-tqerha7lmhgr719hd8qsd09kualf72l9.apps.googleusercontent.com"
        )
    }
    
    func signIn() async throws -> UserAuthData {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            throw AuthError.invalidClientID
//        }
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            throw AuthError.noPresentingViewController
        }
        
        do {
            let result = try await gidSignInInstance.signIn(withPresenting: presentingViewController)
            
            guard let profile = result.user.profile else {
                throw AuthError.noUserProfile
            }

            print("result.serverAuthCode")
            let authCode = result.serverAuthCode ?? "authCode_is_nil"
            print("authCode: \(authCode)")
            print("IDToken: \(result.user.idToken)")
            
            return try await AuthenticationService.shared.getToken(provider: .google, code: authCode)
            
        } catch {
            print("error: \(error.localizedDescription)")
            throw AuthError.signInFailed(error)
        }
    }
    
    func signOut() throws {
        gidSignInInstance.signOut()
    }
}

// 에러 정의
enum AuthError: Error {
    case invalidClientID
    case noPresentingViewController
    case noUserProfile
    case noAuthCode
    case signInFailed(Error)
}
