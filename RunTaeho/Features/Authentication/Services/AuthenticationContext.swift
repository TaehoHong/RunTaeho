import Foundation

// MARK: - 인증 전략 팩토리
class AuthenticationStrategyFactory {
    
    // MARK: - Static Methods
    static func createStrategy(for provider: AuthProvider) -> AuthenticationStrategy? {
        switch provider {
        case .google:
            return GoogleAuthenticationStrategy()
        case .apple:
            return AppleAuthenticationStrategy()
        }
    }
    
    static func getAllAvailableStrategies() -> [AuthenticationStrategy] {
        return AuthProvider.allCases.compactMap { provider in
            createStrategy(for: provider)
        }
    }
    
    static func getAvailableProviders() -> [AuthProvider] {
        return AuthProvider.allCases.filter { provider in
            createStrategy(for: provider) != nil
        }
    }
}

// MARK: - 인증 컨텍스트 (Strategy Pattern의 Context)
class AuthenticationContext: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: UserAuthData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var currentStrategy: AuthenticationStrategy?
    
    // MARK: - Public Methods
    
    /// 인증 전략 설정
    func setStrategy(_ strategy: AuthenticationStrategy) {
        self.currentStrategy = strategy
    }
    
    /// 제공자별 인증 전략 설정
    func setStrategy(for provider: AuthProvider) {
        self.currentStrategy = AuthenticationStrategyFactory.createStrategy(for: provider)
    }
    
    /// 로그인 수행
    func signIn() async {
        guard let strategy = currentStrategy else {
            await MainActor.run {
                self.errorMessage = "인증 전략이 설정되지 않았습니다."
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let userData = try await strategy.signIn()
            
            await MainActor.run {
                self.currentUser = userData
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
                self.isLoading = false
            }
            
            print("Authentication failed: \(error)")
        }
    }
    
    /// 로그아웃 수행
    func signOut() {
        guard let strategy = currentStrategy else {
            self.errorMessage = "인증 전략이 설정되지 않았습니다."
            return
        }
        
        do {
            try strategy.signOut()
            
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = nil
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Sign out failed: \(error)")
        }
    }
    
    /// 현재 로그인 상태 확인
    func checkSignInStatus() {
        guard let strategy = currentStrategy else { return }
        
        self.isAuthenticated = strategy.isSignedIn()
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        self.errorMessage = nil
    }
    
    /// 사용 가능한 인증 제공자 목록
    func getAvailableProviders() -> [AuthProviderType] {
        return AuthenticationStrategyFactory.getAvailableProviders()
    }
}
