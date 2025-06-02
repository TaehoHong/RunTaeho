import SwiftUI

// MARK: - 계정 연결 컴포넌트
struct AccountConnectionComponent: View {
    let account: UserAccount
    let onToggleConnection: (AuthProvider) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // 계정 제공자 텍스트
            Text(account.provider.displayName)
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(Color(hexCode: "000000"))
            
            Spacer()
            
            // 연결 버튼
            Button(action: {
                onToggleConnection(account.provider)
            }) {
                Text(account.isConnected ? "연결중" : "연결")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hexCode: "#000000"))
                    .frame(width: 80, height: 40)
                    .background(
                        Color(hexCode: account.isConnected ? "#7ae87a" : "#d9d9d9")
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 20)
        .frame(width: 380, height: 80)
        .background(Color(hexCode: "#ffffff"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hexCode: "#d9d9d9"), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

// MARK: - 계정 연결 컴포넌트 프리뷰
struct AccountConnectionComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Google 계정 (연결되지 않은 상태)
            AccountConnectionComponent(
                account: UserAccount(
                    provider: .google,
                    isConnected: false,
                    connectedAt: nil,
                    email: nil
                ),
                onToggleConnection: { _ in }
            )
            
            // Apple 계정 (연결된 상태)
            AccountConnectionComponent(
                account: UserAccount(
                    provider: .apple,
                    isConnected: true,
                    connectedAt: Date(),
                    email: "user@icloud.com"
                ),
                onToggleConnection: { _ in }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
