import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                GoogleSignInButton(
                    scheme: .light,
                    style: .wide,
                    action: {
                        viewModel.signIn()
                    })
                .frame(width: 240, height: 38, alignment: .center)
                
                Button(action: {
                    // Apple 로그인 로직
                }) {
                    Image("appleid_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 38)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
            .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
                RunningView()
            }
            .alert("로그인 실패", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) { }
            }
            .navigationTitle("로그인")
        }   
    }
}
