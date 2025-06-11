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
                    AvatarItemCard(item: item) {
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
            
            // Confirm Button
            Button(action: {
                viewModel.confirmChanges()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("확인")
                    .font(CustomFont.custom(size: 22))
                    .foregroundColor(.black)
                    .frame(width: 170, height: 40)
                    .background(Color(hexCode: "7AE87A"))
                    .cornerRadius(5)
            }
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
    let action: () -> Void
    
    private var borderColor: Color {
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
                        .stroke(borderColor, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hexCode: "FAFAFA"))
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
                    
                    // Lock Icon for not owned items
                    if item.status == .notOwned {
                        Image(systemName: "lock.fill")
                            .font(CustomFont.custom(size: 16))
                            .foregroundColor(Color(hexCode: "999999"))
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
                Text("구매하시겠습니까?")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(Color(hexCode: "666666"))
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("취소")
                            .font(CustomFont.custom(size: 20))
                            .foregroundColor(.black)
                            .frame(width: 130, height: 48)
                            .background(Color(hexCode: "D9D9D9"))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onPurchase()
                        isPresented = false
                    }) {
                        Text("구매")
                            .font(CustomFont.custom(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 48)
                            .background(Color(hexCode: "7AE87A"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .frame(width: 320)
        }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct AvatarManagementView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarManagementView()
    }
}
