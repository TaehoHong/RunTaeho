import SwiftUI

// MARK: - 연결 계정 화면 (Navigation 없이)
struct UserAccountConnectionView: View, MenuDisplayable {
    // MARK: - MenuDisplayable 구현
    static var menuTitle: String { "연결 계정 관리" }
    static var menuOrder: Int { 1 }
    
    @StateObject private var viewModel = ConnectedAccountViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HeadingView(title: "연결계정")
            
            // 메인 콘텐츠
            ScrollView {
                VStack(spacing: 25) {
                    
                    // 계정 연결 컴포넌트들
                    accountConnectionSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
            }
            .background(Color.white)
            
            Spacer()
        }
        .background(Color.white)
        .onAppear {
            viewModel.loadConnectedAccounts()
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 계정 연결 섹션
    private var accountConnectionSection: some View {
        VStack(spacing: 20) {
            // 딕셔너리를 배열로 변환하여 ForEach에서 사용
            ForEach(Array(viewModel.connectionStatus.keys), id: \.self) { provider in
                if let status = viewModel.connectionStatus[provider] {
                    AccountConnectionComponent(
                        account: UserAccount(
                            provider: provider,
                            isConnected: status == .connected,
                            connectedAt: status == .connected ? Date() : nil,
                            email: nil
                        ),
                        onToggleConnection: { provider in
                            viewModel.toggleAccountConnection(provider: provider)
                        }
                    )
                }
            }
            
            // 연결 상태가 없는 경우 기본 계정들 표시
            if viewModel.connectionStatus.isEmpty {
                ForEach(AuthProvider.allCases, id: \.self) { provider in
                    AccountConnectionComponent(
                        account: UserAccount(
                            provider: provider,
                            isConnected: false,
                            connectedAt: nil,
                            email: nil
                        ),
                        onToggleConnection: { provider in
                            viewModel.toggleAccountConnection(provider: provider)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - 연결 계정 화면 프리뷰
struct ConnectedAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountConnectionView()
            .previewDevice("iPhone 14")
    }
}
