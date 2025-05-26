import SwiftUI

// 필터 버튼
struct FilterButton: View {
    @Binding var selectedFilter: PointFilter
    @Binding var showDropdown: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDropdown.toggle()
            }
        }) {
            HStack(spacing: 2) {
                Text(selectedFilter.displayName)
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(Color(hexCode: "333333"))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hexCode: "333333"))
                    .rotationEffect(.degrees(showDropdown ? 180 : 0))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hexCode: "f2f2f2").opacity(0.01))
            .cornerRadius(8)
        }
    }
}
