import SwiftUI

// MARK: - 계정 연결 컴포넌트
struct AccountConnectionComponent: View {
    let account: UserAccount
    let onToggleConnection: (AuthProvider) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // 계정 제공자 텍스트
            Text(account.provider.displayName)
                .font(CustomFont.custom(size: 24))
                .foregroundColor(Color(hexCode: "000000"))
            
            Spacer()
            
            // 연결 버튼
            Button(action: {
                onToggleConnection(account.provider)
            }) {
                Text(account.isConnected ? "연결중" : "연결")
                    .font(CustomFont.custom(size: 18))
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

