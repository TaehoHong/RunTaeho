import Foundation
import Combine

// MARK: - 연결 계정 뷰모델
@MainActor
class ConnectedAccountViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var errorMessage: String?
    @Published var connectionStatus: [AuthProvider: AccountConnectionStatus] = [:]
    
    
    // MARK: - Private Properties
    private let userStateManager = UserStateManager.shared
    private let authContext = AuthenticationContext.shared
    private let userAccountService = UserAccountService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadConnectedAccounts()
    }
    
    // MARK: - Public Methods
    
    /// 연결된 계정 목록 로드
    func loadConnectedAccounts(accounts: [UserAccount] = []) {
        Task {
            let accounts = userStateManager.getUserAccounts()
            
            do {
                // 연결 상태 업데이트
                for account in accounts {
                    self.connectionStatus[account.provider] = account.isConnected ? .connected : AccountConnectionStatus.none
                }
                
            } catch {
                self.errorMessage = "연결된 계정을 불러오는데 실패했습니다."
                print("Error loading connected accounts: \(error)")
            }
        }
    }
    
    /// 계정 연결/해제 토글
    func toggleAccountConnection(provider: AuthProvider) {
        Task {
            do {
                authContext.setStrategy(for: provider)
                let isCurrentlyConnected = self.connectionStatus[provider] == .connected
                
                let success: Bool
                if isCurrentlyConnected {
                    success = userAccountService.disconnect(provider: provider)
                } else {
                    success = try await authContext.signIn() != nil
                }
                
                if success {
                    // 연결 상태 업데이트
                    self.connectionStatus[provider] = isCurrentlyConnected ? AccountConnectionStatus.none : .connected
                    
                    // 계정 목록 새로고침
                    loadConnectedAccounts()
                } else {
                    self.connectionStatus[provider] = AccountConnectionStatus.none
                    self.errorMessage = "\(provider.displayName) 계정 \(isCurrentlyConnected ? "연결 해제" : "연결")에 실패했습니다."
                }
            } catch {
                self.connectionStatus[provider] = AccountConnectionStatus.none
                self.errorMessage = "\(provider.displayName) 계정 연결 중 오류가 발생했습니다."
                print("Error toggling account connection: \(error)")
            }
        }
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        errorMessage = nil
    }
}
