import SwiftUI

struct RootView: View {
    @StateObject private var userStateManager = UserStateManager.shared
    @State private var isInitialized = false
    
    var body: some View {
        Group {
            if isInitialized {
                if userStateManager.isLoggedIn {
                    MainTabView()
                        .transition(.move(edge: .trailing))
                } else {
                    LoginView()
                        .transition(.move(edge: .leading))
                }
            } else {
                // 초기화 중 로딩 화면
                ProgressView("로딩 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray)
            }
        }
        .animation(.easeInOut, value: userStateManager.isLoggedIn)
        .task {
            // 약간의 지연을 두어 초기화 완료 보장
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
            withAnimation {
                isInitialized = true
            }
        }
    }
}
