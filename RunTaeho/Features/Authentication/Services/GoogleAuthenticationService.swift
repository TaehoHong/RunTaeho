import GoogleSignIn
import GoogleSignInSwift

class GoogleAuthenticationService: AuthenticationProtocol {
    static let shared = GoogleAuthenticationService()
    private init() {}
    
    func signIn() async throws -> UserData {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            throw AuthError.invalidClientID
//        }
        
        let clientID = "620303212609-581f7f3bgj104gtaermbtjqqf8u6khb8.apps.googleusercontent.com"
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            throw AuthError.noPresentingViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let profile = result.user.profile else {
                throw AuthError.noUserProfile
            }
            
            return UserData(
                url: profile.imageURL(withDimension: 180),
                name: profile.name,
                email: profile.email
            )
        } catch {
            throw AuthError.signInFailed(error)
        }
    }
    
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
    }
}

// 에러 정의
enum AuthError: Error {
    case invalidClientID
    case noPresentingViewController
    case noUserProfile
    case signInFailed(Error)
}
