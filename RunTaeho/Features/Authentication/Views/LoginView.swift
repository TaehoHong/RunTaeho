import SwiftUI
import GoogleSignInSwift

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
                        viewModel.signIn(with: .google)
                    })
                .frame(width: 240, height: 38, alignment: .center)

                Button(action: {
                    print("[LoginView] Apple/Debug 버튼 클릭")
                    viewModel.signInDebugg()
//                    viewModel.signIn(with: .apple)
                }) {
                    Image("appleid_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 38)
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
        }
    }
}
