import SwiftUI

// MARK: - Main Purchase Confirmation Popup
struct PurchaseConfirmationPopup: View {
    @StateObject private var viewModel: PurchaseViewModel
    @Binding var isPresented: Bool
    let onPurchase: () -> Void
    
    init(items: [PurchaseItemViewModel], userPoints: Int, isPresented: Binding<Bool>, onPurchase: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: PurchaseViewModel(items: items, userPoints: userPoints))
        self._isPresented = isPresented
        self.onPurchase = onPurchase
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Popup content
            PurchasePopupContent(
                viewModel: viewModel,
                isPresented: $isPresented,
                onPurchase: onPurchase
            )
        }
    }
}

// MARK: - Popup Content Container
struct PurchasePopupContent: View {
    @ObservedObject var viewModel: PurchaseViewModel
    @Binding var isPresented: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            PurchasePopupTitle()
            
            // Items List
            PurchaseItemListView(items: viewModel.items)
            
            // Divider
            PurchaseDivider()
                .padding(.vertical, 16)
            
            // Price Summary
            PriceSummaryView(
                userPoints: viewModel.userPoints,
                totalPrice: viewModel.totalPrice,
                remainingPoints: viewModel.remainingPoints,
                canPurchase: viewModel.canPurchase
            )
            
            // Warning message
            if !viewModel.canPurchase {
                PurchaseWarningMessage(text: "포인트가 부족합니다")
            }
            
            // Buttons
            PurchaseButtonGroup(
                canPurchase: viewModel.canPurchase,
                onCancel: { isPresented = false },
                onPurchase: {
                    viewModel.processPurchase {
                        onPurchase()
                        isPresented = false
                    }
                }
            )
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hexCode: "CCCCCC"), lineWidth: 1)
        )
        .cornerRadius(8)
        .frame(width: 340)
    }
}

// MARK: - Title Component
struct PurchasePopupTitle: View {
    var body: some View {
        Text("아이템 구매")
            .font(CustomFont.custom(size: 24))
            .foregroundColor(.black)
            .padding(.top, 24)
            .padding(.bottom, 20)
    }
}

// MARK: - Divider Component
struct PurchaseDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hexCode: "E6E6E6"))
            .frame(height: 1)
    }
}

// MARK: - Warning Message Component
struct PurchaseWarningMessage: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(CustomFont.custom(size: 12))
            .foregroundColor(Color(hexCode: "FF0000"))
            .padding(.top, 8)
    }
}

// MARK: - Items List Component
struct PurchaseItemListView: View {
    let items: [PurchaseItemViewModel]

    private let itemHeight: CGFloat = 70
    private let itemSpacing: CGFloat = 1
    private let maxVisibleItems: Int = 3

    private var listHeight: CGFloat {
        let itemCount = min(items.count, maxVisibleItems)
        let totalItemHeight = CGFloat(itemCount) * itemHeight
        let totalSpacing = CGFloat(max(0, itemCount - 1)) * itemSpacing
        return totalItemHeight + totalSpacing
    }

    var body: some View {
        ScrollView {
            VStack(spacing: itemSpacing) {
                ForEach(items) { item in
                    PurchaseItemRow(item: item)
                        .frame(height: itemHeight)
                }
            }
        }
        .frame(height: listHeight)
        .scrollDisabled(items.count <= maxVisibleItems)
    }
}

// MARK: - Item Row Component
struct PurchaseItemRow: View {
    let item: PurchaseItemViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Item Info
            VStack(alignment: .leading, spacing: 6) {
                Image(item.imagePath)
                    .foregroundColor(.black)
//                    .frame(width: 36, height: 36)
//                Text(item.categoryName)
//                    .font(CustomFont.custom(size: 14))
//                    .foregroundColor(Color(hexCode: "666666"))
            }
            
            Spacer()
            
            // Price
            PriceDisplay(price: item.price)
        }
        .padding(.horizontal, 50)
        .padding(.vertical, 8)
        .background(Color.white)
//        .background(Color(hexCode: "F8F8F8"))
        .cornerRadius(8)
    }
}

// MARK: - Price Display Component
struct PriceDisplay: View {
    let price: Int
    
    var body: some View {
        HStack(spacing: 3) {
            PointIcon()
            
            Text("\(price)")
                .font(CustomFont.custom(size: 16))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Point Icon Component
struct PointIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hexCode: "7BE87B"))
                .frame(width: 16, height: 16)
            
            Text("P")
                .font(CustomFont.custom(size: 9))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Price Summary Component
struct PriceSummaryView: View {
    let userPoints: Int
    let totalPrice: Int
    let remainingPoints: Int
    let canPurchase: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            PriceSummaryRow(
                label: "보유 포인트",
                value: "\(userPoints)P",
                valueColor: Color(hexCode: "4D4D4D")
            )
            
            PriceSummaryRow(
                label: "총 구매 금액",
                value: "-\(totalPrice)P",
                valueColor: Color(hexCode: "FF0000")
            )
            
            PurchaseDivider()
            
            HStack {
                Text("구매 후 남은 포인트")
                    .font(CustomFont.custom(size: 14))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(remainingPoints)P")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(canPurchase ? Color(hexCode: "009900") : Color(hexCode: "FF0000"))
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Price Summary Row Component
struct PriceSummaryRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(CustomFont.custom(size: 14))
                .foregroundColor(Color(hexCode: "4D4D4D"))
            
            Spacer()
            
            Text(value)
                .font(CustomFont.custom(size: 14))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Button Group Component
struct PurchaseButtonGroup: View {
    let canPurchase: Bool
    let onCancel: () -> Void
    let onPurchase: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            CancelButton(action: onCancel)
            PurchaseButton(canPurchase: canPurchase, action: onPurchase)
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Cancel Button Component
struct CancelButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("취소")
                .font(CustomFont.custom(size: 14))
                .foregroundColor(Color(hexCode: "666666"))
                .frame(width: 120, height: 35)
                .background(Color(hexCode: "F2F2F2"))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hexCode: "CCCCCC"), lineWidth: 1)
                )
                .cornerRadius(5)
        }
    }
}

// MARK: - Purchase Button Component
struct PurchaseButton: View {
    let canPurchase: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if canPurchase {
                action()
            }
        }) {
            Text("구매")
                .font(CustomFont.custom(size: 14))
                .foregroundColor(.white)
                .frame(width: 120, height: 35)
                .background(canPurchase ? Color(hexCode: "70DBFA") : Color(hexCode: "CCCCCC"))
                .cornerRadius(5)
        }
        .disabled(!canPurchase)
    }
}
