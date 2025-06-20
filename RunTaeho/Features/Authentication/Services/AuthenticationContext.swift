import Foundation

// MARK: - 인증 전략 팩토리
class AuthenticationStrategyFactory {
    
    // MARK: - Static Methods
    static func createStrategy(for provider: AuthProvider) -> AuthenticationStrategy? {
        switch provider {
        case .GOOGLE:
            return GoogleAuthenticationStrategy()
        case .APPLE:
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
    
    static let shared = AuthenticationContext()
    
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var currentStrategy: AuthenticationStrategy?
    private let userAccountService = UserAccountService.shared
    
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
    func signIn() async throws -> UserAuthData? {
        guard let strategy = currentStrategy else {
            await MainActor.run {
                self.errorMessage = "인증 전략이 설정되지 않았습니다."
            }
            return nil
        }
        
        do {
            return try await strategy.signIn()
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            
            print("Authentication failed: \(error)")
        }
        
        return nil
    }
    
    /// 로그아웃 수행
    func signOut() {
        guard let strategy = currentStrategy else {
            self.errorMessage = "인증 전략이 설정되지 않았습니다."
            return
        }
        
        do {
            try strategy.signOut()
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Sign out failed: \(error)")
        }
    }
    
    func disconnect() {
        
        guard let strategy = currentStrategy else {
            self.errorMessage = "인증 전략이 설정되지 않았습니다."
            return
        }
        
        do {
            try strategy.signOut()
            userAccountService.disconnect(provider: currentStrategy!.authProvider)
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Sign out failed: \(error)")
        }
        
    }
    
    /// 현재 로그인 상태 확인
    func checkSignInStatus() {
        guard let strategy = currentStrategy else { return }
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        self.errorMessage = nil
    }
    
    /// 사용 가능한 인증 제공자 목록
    func getAvailableProviders() -> [AuthProvider] {
        return AuthenticationStrategyFactory.getAvailableProviders()
    }
}
