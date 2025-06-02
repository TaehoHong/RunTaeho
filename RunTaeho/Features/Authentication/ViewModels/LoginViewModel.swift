import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published public var isLoggedIn = false
    @Published public var userAuthData: UserAuthData?
    @Published var showError = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Strategy Pattern Integration
    private let authContext = AuthenticationContext()
    
    init() {
        // 기본적으로 Google 전략 설정
        authContext.setStrategy(for: .google)
    }
    
    // MARK: - Authentication Methods
    
    /// 특정 제공자로 로그인
    func signIn(with provider: AuthProvider) {
        Task {
            authContext.setStrategy(for: provider)
            await authContext.signIn()
            
            // AuthContext 상태를 ViewModel에 반영
            self.isLoggedIn = authContext.isAuthenticated
            self.userAuthData = authContext.currentUser
            self.isLoading = authContext.isLoading
            self.errorMessage = authContext.errorMessage
            self.showError = authContext.errorMessage != nil
        }
    }
    
    /// Google 로그인 (기존 호환성)
    func signIn() {
        signIn(with: .google)
    }
    
    /// 로그아웃
    func signOut() {
        authContext.signOut()
        
        // 상태 업데이트
        self.isLoggedIn = authContext.isAuthenticated
        self.userAuthData = authContext.currentUser
        self.errorMessage = authContext.errorMessage
        self.showError = authContext.errorMessage != nil
    }
    
    /// 디버그 로그인
    func signInDebugg() {
        Task {
            isLoggedIn = true
        }
    }
    
    /// 사용 가능한 인증 제공자 목록 가져오기
    func getAvailableProviders() -> [AuthProviderType] {
        return authContext.getAvailableProviders()
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        authContext.clearError()
        self.showError = false
        self.errorMessage = nil
    }
}
