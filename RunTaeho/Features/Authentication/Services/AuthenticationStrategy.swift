import Foundation

// MARK: - 인증 전략 프로토콜
protocol AuthenticationStrategy {
    var authProvider: AuthProvider { get }
    
    func signIn() async throws -> UserAuthData
    func signOut() throws
    func isSignedIn() -> Bool
}

// MARK: - 인증 에러
enum AuthenticationError: Error, LocalizedError {
    case invalidClientID
    case noPresentingViewController
    case noUserProfile
    case noAuthCode
    case signInFailed(Error)
    case unsupportedProvider
    case networkError(Error)
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidClientID:
            return "잘못된 클라이언트 ID입니다."
        case .noPresentingViewController:
            return "화면을 표시할 수 없습니다."
        case .noUserProfile:
            return "사용자 프로필을 가져올 수 없습니다."
        case .noAuthCode:
            return "인증 코드를 가져올 수 없습니다."
        case .signInFailed(let error):
            return "로그인에 실패했습니다: \(error.localizedDescription)"
        case .unsupportedProvider:
            return "지원하지 않는 인증 제공자입니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .userCancelled:
            return "사용자가 로그인을 취소했습니다."
        }
    }
}
