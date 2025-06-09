import Foundation
import Combine


class UserAccountService {
        
    static let shared = UserAccountService()
    private let userStateManager = UserStateManager.shared

    func getConnectedAccounts() async throws -> [UserAccount] {
        // TODO: 실제 API 호출로 대체
        return [
            UserAccount(
                provider: .google,
                isConnected: false,
                connectedAt: nil,
                email: nil
            ),
            UserAccount(
                provider: .apple,
                isConnected: true,
                connectedAt: Date(),
                email: "user@icloud.com"
            )
        ]
    }
    
    func disconnect(provider: AuthProvider) -> Bool {
        return true
    }
}
