import SwiftUI

// 필터 드롭다운 메뉴
struct FilterDropdown: View {
    @Binding var selectedFilter: PointFilter
    @Binding var showDropdown: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(PointFilter.allCases.enumerated()), id: \.offset) { index, filter in
                FilterOption(filter: filter, selectedFilter: $selectedFilter, showDropdown: $showDropdown)
                
                if index < PointFilter.allCases.count - 1 {
                    Divider()
                        .background(Color(hexCode: "e6e6e6"))
                }
            }
        }
        .frame(width: 100)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}
