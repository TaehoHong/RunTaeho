import SwiftUI

struct AvatarManagementView: View {
    @StateObject private var viewModel = AvatarManagementViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showPurchaseConfirmation = false
    @State private var selectedItemForPurchase: AvatarItem?
    
    var body: some View {
        ZStack {
            // Background
            Color(hexCode: "FAFAFA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 10)
                
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
            if showPurchaseConfirmation, let item = selectedItemForPurchase {
                PurchaseConfirmationPopup(
                    item: item,
                    isPresented: $showPurchaseConfirmation,
                    onPurchase: {
                        viewModel.purchaseItem()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$showPurchaseConfirmation) { show in
            showPurchaseConfirmation = show
        }
        .onReceive(viewModel.$selectedItemForPurchase) { item in
            selectedItemForPurchase = item
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("<")
                    .font(CustomFont.custom(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Title
            Text("아바타")
                .font(CustomFont.custom(size: 24))
                .foregroundColor(.black)
            
            Spacer()
            
            // Points
            HStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(Color(hexCode: "7BE87B"))
                        .frame(width: 21, height: 21)
                    
                    Text("P")
                        .font(CustomFont.custom(size: 12))
                        .foregroundColor(.white)
                }
                
                Text("\(viewModel.avatarState.userPoints)")
                    .font(CustomFont.custom(size: 25))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Avatar Preview View
    private var avatarPreviewView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(height: 300)
            
            VStack {
                Image(systemName: "person.fill")
                    .font(CustomFont.custom(size: 80))
                    .foregroundColor(Color(hexCode: "E0E0E0"))
                    .padding(.bottom, 20)
                
                Text("Unity View 추가 예정")
                    .font(CustomFont.custom(size: 22))
                    .foregroundColor(Color(hexCode: "999999"))
            }
        }
    }
    
    // MARK: - Category Tabs View
    private var categoryTabsView: some View {
        HStack(spacing: 0) {
            ForEach(AvatarCategory.allCases, id: \.self) { category in
                CategoryTab(
                    category: category,
                    isSelected: viewModel.avatarState.selectedCategory == category,
                    action: {
                        viewModel.selectCategory(category)
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
                ForEach(viewModel.filteredItems) { item in
                    AvatarItemCard(
                        item: item,
                        isSelected: viewModel.isItemSelected(item),
                        showPrice: item.status == .notOwned
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
                if viewModel.shouldShowPurchaseButton {
                    viewModel.attemptPurchase()
                } else {
                    viewModel.confirmChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text(viewModel.shouldShowPurchaseButton ? "구매" : "확인")
                    .font(CustomFont.custom(size: 22))
                    .foregroundColor(viewModel.shouldShowPurchaseButton ? .black : .black)
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
    let category: AvatarCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
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
    let item: AvatarItem
    let isSelected: Bool
    let showPrice: Bool
    let action: () -> Void
    
    private var borderColor: Color {
        if isSelected && item.status == .notOwned {
            return Color(hexCode: "888888")
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
                        .fill(isSelected && item.status == .notOwned ? Color(hexCode: "888888") : Color(hexCode: "FAFAFA"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 2)
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Group {
                                if let imageName = item.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(10)
                                        .opacity(item.status == .notOwned ? 0.5 : 1.0)
                                } else {
                                    Image(systemName: "photo")
                                        .font(CustomFont.custom(size: 40))
                                        .foregroundColor(Color(hexCode: "CCCCCC"))
                                        .opacity(item.status == .notOwned ? 0.5 : 1.0)
                                }
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
                
                // Item Name
                Text(item.name)
                    .font(CustomFont.custom(size: 12))
                    .foregroundColor(textColor)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Purchase Confirmation Popup
struct PurchaseConfirmationPopup: View {
    let item: AvatarItem
    @Binding var isPresented: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Popup content
            VStack(spacing: 24) {
                // Title
                Text("아이템 구매")
                    .font(CustomFont.custom(size: 24))
                    .foregroundColor(.black)
                
                // Item Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hexCode: "F5F5F5"))
                        .frame(width: 120, height: 120)
                    
                    if let imageName = item.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    } else {
                        Image(systemName: "photo")
                            .font(CustomFont.custom(size: 40))
                            .foregroundColor(Color(hexCode: "CCCCCC"))
                    }
                }
                
                // Item Name
                Text(item.name)
                    .font(CustomFont.custom(size: 18))
                    .foregroundColor(.black)
                
                // Price
                if let price = item.price {
                    Text("\(price) P")
                        .font(CustomFont.custom(size: 28))
                        .foregroundColor(Color(hexCode: "7AE87A"))
                }
                
                // Message
                VStack(spacing: 16) {
                Text("구매 확인")
                    .font(CustomFont.custom(size: 18))
                            .foregroundColor(.black)
                        
                        VStack(spacing: 8) {
                            Text("보유 포인트: \(viewModel.avatarState.userPoints)P")
                                .font(CustomFont.custom(size: 14))
                                .foregroundColor(Color(hexCode: "4D4D4D"))
                            
                            if let price = item.price {
                                Text("아이템 가격: \(price)P")
                                    .font(CustomFont.custom(size: 14))
                                    .foregroundColor(Color(hexCode: "4D4D4D"))
                                
                                Rectangle()
                                    .fill(Color(hexCode: "E6E6E6"))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                                
                                Text("구매 후 남은 포인트: \(viewModel.avatarState.userPoints - price)P")
                                    .font(CustomFont.custom(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hexCode: "009900"))
                            }
                        }
                    }
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("취소")
                            .font(CustomFont.custom(size: 14, weight: .medium))
                            .foregroundColor(Color(hexCode: "666666"))
                            .frame(width: 120, height: 35)
                            .background(Color(hexCode: "F2F2F2"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(hexCode: "CCCCCC"), lineWidth: 1)
                            )
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        onPurchase()
                        isPresented = false
                    }) {
                        Text("확인")
                            .font(CustomFont.custom(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 35)
                            .background(Color(hexCode: "70DBFA"))
                            .cornerRadius(5)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hexCode: "CCCCCC"), lineWidth: 1)
            )
            .cornerRadius(8)
            .frame(width: 300)
        }
    }
}
