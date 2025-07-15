import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Single Source of Truth
    private let userStateManager = UserStateManager.shared
    private let userService = UserService.shared
    private let authContext = AuthenticationContext.shared
    
    // MARK: - Computed Properties (읽기 전용)
    var isLoggedIn: Bool { userStateManager.isLoggedIn }
    var currentUser: User? { userStateManager.currentUser }
    
    // MARK: - Local State (UI 전용)
    @Published var showError = false
    @Published var errorMessage: String?
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 기본적으로 Google 전략 설정
        authContext.setStrategy(for: .GOOGLE)
        
        // init에서 바로 구독하지 않고 다음 런루프에서 설정
        Task { @MainActor in
            setupBindings()
        }
    }
    
    private func setupBindings() {
        
        // AuthContext의 에러 메시지를 구독
        authContext.$errorMessage
            .receive(on: DispatchQueue.main)
            .removeDuplicates()  // 중복 값 제거
            .sink { [weak self] error in
                guard let self = self else { return }
                
                // 다음 런루프에서 실행하여 뷰 업데이트 사이클 충돌 방지
                DispatchQueue.main.async {
                    self.errorMessage = error
                    self.showError = error != nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    
    /// 특정 제공자로 로그인
    func signIn(with provider: AuthProvider) {
        Task { @MainActor in
            print("[LoginViewModel] signIn 시작")
            
            authContext.setStrategy(for: provider)
            let userAuthData = try await authContext.signIn()
            
            // 로그인 성공 시 UserStateManager 업데이트
            if userAuthData != nil {
                
                print("[LoginViewModel] 인증 성공, User 객체 생성 중...")
                let userDataDto = try await userService.getUserDatadto(accessToken: userAuthData!.accessToken)
            
                print("[LoginViewModel] UserStateManager.login 호출 전")
                
                // 메인 큐에서 비동기로 실행
                await MainActor.run {
                    userStateManager.login(
                        userData: userDataDto,
                        authToken: userAuthData!.accessToken,
                        refreshToken: userAuthData!.refreshToken
                    )
                }
                
                print("[LoginViewModel] UserStateManager.login 호출 완료")
            }
        }
    }
    /// 로그아웃
    func signOut() {
        authContext.signOut()
        
        // UserStateManager를 통해 로그아웃 처리
        userStateManager.logout()
    }
    
    /// 디버그 로그인
    func signInDebugg() {
        Task {
            // 테스트용 사용자 데이터 생성
            let debugUser = UserDataDto(
                id: 1234,
                name: "테스트 사용자",
                authorityType: "USER",
                totalPoint: 10000,
                userAccounts: [
                    UserAccountDataDto(
                        id: 1,
                        email: "debug@gmail.com",
                        accountType: .GOOGLE
                    ),
                    UserAccountDataDto(
                        id: 2,
                        email: "debug@icloud.com",
                        accountType: .APPLE
                    )
                ],
                equippedItems: [
                    EquippedItemDataDto(
                        id: 1,
                        name: "New_Hair_01",
                        itemTypeId: 1,
                        filePath: "items/Hair/",
                        unityFilePath: "Assets/05.Resource/Hair/"
                    )
                ]
            )
            
            // UserStateManager를 통해 로그인 처리
            userStateManager.login(
                userData: debugUser,
                authToken: "debug_access_token",
                refreshToken: "debug_refresh_token"
            )
        }
    }
    
    /// 사용 가능한 인증 제공자 목록 가져오기
    func getAvailableProviders() -> [AuthProvider] {
        return authContext.getAvailableProviders()
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        authContext.clearError()
        self.showError = false
        self.errorMessage = nil
    }
}
