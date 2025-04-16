import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published public var isLoggedIn = false
    @Published public var userAuthData: UserAuthData?
    @Published var showError = false
    
    private let authService: AuthenticationProtocol
    
    init(authService: AuthenticationProtocol = GoogleAuthenticationService.shared) {
        self.authService = authService
    }
    
    func signIn() {
        Task {
            do {
                userAuthData = try await authService.signIn()
                isLoggedIn = true
            } catch {
                showError = true
            }
        }
    }
}
