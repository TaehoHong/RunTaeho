import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var userStateManager: UserStateManager

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                GoogleSignInButton(
                    scheme: .light,
                    style: .wide,
                    action: {
                        viewModel.signIn(with: .google)
                    })
                .frame(width: 240, height: 38, alignment: .center)
                .disabled(viewModel.isLoading)

                Button(action: {
                    viewModel.signInDebugg()
//                    viewModel.signIn(with: .apple)
                }) {
                    Image("appleid_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 38)
                }
                .disabled(viewModel.isLoading)
                
                // 디버그 버튼 (개발용)
                #if DEBUG
                Button("디버그 로그인") {
                    // 더미 사용자 데이터로 로그인
                    let dummyUser = User(
                        id: 1,
                        email: "test@example.com",
                        nickname: "달려라 태호군",
                        totalPoints: 10000
                    )
                    userStateManager.login(
                        user: dummyUser,
                        authToken: "dummy_token"
                    )
                }
                .padding(.top, 20)
                .foregroundColor(.blue)
                #endif
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView("로그인 중...")
                        .padding(.top, 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
            .alert("로그인 실패", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationTitle("로그인")
            // MARK: - UserStateManager와 연동
            .onChange(of: viewModel.isLoggedIn) {
                if viewModel.isLoggedIn, let userData = viewModel.userAuthData {
                    // UserAuthData를 User 모델로 변환
                    let user = User(
                        id: userData.id,
                        email: userData.email,
                        nickname: userData.nickname
                    )
                    
                    // UserStateManager로 로그인 상태 업데이트
                    userStateManager.login(
                        user: user,
                        authToken: userData.accessToken,
                        refreshToken: userData.refreshToken
                    )
                }
            }
            .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
                MainTabView()
            }
        }
    }
}
