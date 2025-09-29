import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @ObservedObject private var userStateManager = UserStateManager.shared

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                GoogleSignInButton(
                    scheme: .light,
                    style: .wide,
                    action: {
                        viewModel.signIn(with: .GOOGLE)
                    })
                .frame(width: 240, height: 38, alignment: .center)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        // ViewModel을 통해 Apple 결과 처리
                        switch result {
                              case .success(let authorization):
                                AppleAuthenticationStrategy.shared.setAppleSignInResult(authorization)
                                viewModel.signIn(with: .APPLE)
                              case .failure(let error):
                                AppleAuthenticationStrategy.shared.setAppleSignInError(error)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 240, height: 38)
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
        }
    }
}
