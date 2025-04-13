import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published public var isLoggedIn = false
    @Published private(set) var userData: UserData?
    @Published var showError = false
    
    private let authService: AuthenticationProtocol
    
    init(authService: AuthenticationProtocol = GoogleAuthenticationService.shared) {
        self.authService = authService
    }
    
    func signIn() {
        Task {
            do {
                userData = try await authService.signIn()
                isLoggedIn = true
            } catch {
                showError = true
            }
        }
    }
}
