import SwiftUI

struct AvatarManagementView: View {
    @StateObject private var viewModel = AvatarManagementViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showPurchaseConfirmation = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hexCode: "FAFAFA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    HeadingView(title: "아바타")
                    HStack {
                        Spacer()
                        Image("PointIcon")
                            .resizable()
                            .frame(width: 22, height: 22)
                        
                    
                        Text("\(viewModel.totalPoint)")
                            .font(CustomFont.custom(size: 25))
                            .foregroundColor(.black)
                    }.padding(.horizontal, 20)
                }
                
//                headerView
//                    .padding(.top, 10)
                
                // Avatar Preview
                avatarPreviewView
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Category Tabs
                categoryTabsView
                    .padding(.top, 20)
                
                // Items Grid
                itemsGridView
                    .padding(.top, 20)
                
                Spacer()
                
                // Bottom Buttons
                bottomButtonsView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Purchase Confirmation Popup
            if showPurchaseConfirmation {
                PurchaseView(
                    items: viewModel.itemsToPurchase,
                    userPoints: viewModel.totalPoint,
                    isPresented: $showPurchaseConfirmation,
                    onPurchase: {
                        viewModel.confirmPurchase()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$showPurchaseConfirmation) { show in
            showPurchaseConfirmation = show
        }
    }
    
    // MARK: - Avatar Preview View
    private var avatarPreviewView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(height: 300)
            
//             Unity View 연동 부분
             UnityAvatarView(equippedItems: viewModel.currentPreviewItems)
                .frame(height: 300)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Category Tabs View
    private var categoryTabsView: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.categories.indices, id: \.self) { index in
                CategoryTab(
                    category: viewModel.categories[index],
                    isSelected: viewModel.selectedCategoryIndex == index,
                    action: {
                        viewModel.selectCategory(at: index)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .background(Color.white)
    }
    
    // MARK: - Items Grid View
    private var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(viewModel.currentCategoryItems) { item in
                    AvatarItemCard(
                        item: item,
                        isSelected: viewModel.isItemSelected(item),
                        showPrice: !item.isOwned
                    ) {
                        viewModel.selectItem(item)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.white)
    }
    
    // MARK: - Bottom Buttons View
    private var bottomButtonsView: some View {
        HStack(spacing: 20) {
            // Cancel Button
            Button(action: {
                viewModel.cancelChanges()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("취소")
                    .font(CustomFont.custom(size: 22))
                    .foregroundColor(.black)
                    .frame(width: 170, height: 40)
                    .background(Color(hexCode: "D9D9D9"))
                    .cornerRadius(5)
            }
            .disabled(!viewModel.hasChanges)
            .opacity(viewModel.hasChanges ? 1.0 : 0.6)
            
            // Confirm or Purchase Button
            Button(action: {
                viewModel.confirmChanges()
                // 구매 버튼이든 확인 버튼이든 화면을 닫지 않음
            }) {
                Text(viewModel.shouldShowPurchaseButton ? "구매" : "확인")
                    .font(CustomFont.custom(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 170, height: 40)
                    .background(viewModel.shouldShowPurchaseButton ? Color(hexCode: "71DCF9") : Color(hexCode: "7AE87A"))
                    .cornerRadius(5)
            }
            .disabled(!viewModel.hasChanges)
            .opacity(viewModel.hasChanges ? 1.0 : 0.6)
        }
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let category: CategoryViewModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(CustomFont.custom(size: 18))
                .foregroundColor(isSelected ? .black : Color(hexCode: "666666"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color(hexCode: "7AE87A") : Color(hexCode: "F2F2F2"))
        }
    }
}

// MARK: - Avatar Item Card
struct AvatarItemCard: View {
    let item: AvatarItemViewModel
    let isSelected: Bool
    let showPrice: Bool
    let action: () -> Void
    
    private var borderColor: Color {
        if isSelected {
            // 선택된 상태에서는 항상 강조 테두리
            return Color(hexCode: "7AE87A")
        }
        switch item.status {
        case .equipped:
            return Color(hexCode: "7AE87A")
        case .owned:
            return Color.black
        case .notOwned:
            return Color(hexCode: "888888")
        }
    }
    
    private var textColor: Color {
        switch item.status {
        case .equipped:
            return Color(hexCode: "333333")
        case .owned:
            return Color.black
        case .notOwned:
            return Color(hexCode: "999999")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    // Item Image Container
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(hexCode: "E8F5E8") : Color(hexCode: "FAFAFA"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: isSelected ? 3 : 2)
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Group {
                                Image(item.imagePath)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(20)
                                    .foregroundColor(Color(hexCode: "CCCCCC"))
                                    .opacity(item.status == .notOwned ? 0.5 : 1.0)
                            }
                        )
                    
                    // Price for not owned items when selected
                    if isSelected && showPrice, let price = item.price {
                        HStack(spacing: 2) {
                            ZStack {
                                Circle()
                                    .fill(Color(hexCode: "7BE87B"))
                                    .frame(width: 16, height: 16)
                                
                                Text("P")
                                    .font(CustomFont.custom(size: 9))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(price)")
                                .font(CustomFont.custom(size: 14))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(8)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
