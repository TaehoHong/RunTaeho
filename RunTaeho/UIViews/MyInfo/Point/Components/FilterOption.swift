import SwiftUI

// 필터 옵션 항목
struct FilterOption: View {
    let filter: PointFilter
    @Binding var selectedFilter: PointFilter
    @Binding var showDropdown: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = filter
                showDropdown = false
            }
        }) {
            HStack {
                Text(filter.displayName)
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(selectedFilter == filter ? Color(hexCode: "339933") : Color(hexCode: "333333"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selectedFilter == filter ? Color(hexCode: "339933").opacity(0.1) : Color.clear)
        }
    }
}
