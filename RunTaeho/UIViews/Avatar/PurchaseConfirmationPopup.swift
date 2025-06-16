import SwiftUI

// MARK: - Purchase Confirmation Popup (Updated)
struct PurchaseConfirmationPopup: View {
    let items: [PurchaseItemViewModel]
    let userPoints: Int
    @Binding var isPresented: Bool
    let onPurchase: () -> Void
    
    private var totalPrice: Int {
        items.reduce(0) { $0 + $1.price }
    }
    
    private var remainingPoints: Int {
        userPoints - totalPrice
    }
    
    private var canPurchase: Bool {
        remainingPoints >= 0
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
            VStack(spacing: 0) {
                // Title
                Text("아이템 구매")
                    .font(CustomFont.custom(size: 24))
                    .foregroundColor(.black)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                
                // Items List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(items) { item in
                            HStack(spacing: 12) {
                                // Item Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(CustomFont.custom(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Text(item.categoryName)
                                        .font(CustomFont.custom(size: 12))
                                        .foregroundColor(Color(hexCode: "666666"))
                                }
                                
                                Spacer()
                                
                                // Price
                                HStack(spacing: 3) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hexCode: "7BE87B"))
                                            .frame(width: 16, height: 16)
                                        
                                        Text("P")
                                            .font(CustomFont.custom(size: 9))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("\(item.price)")
                                        .font(CustomFont.custom(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .frame(maxHeight: 200)
                
                // Divider
                Rectangle()
                    .fill(Color(hexCode: "E6E6E6"))
                    .frame(height: 1)
                    .padding(.vertical, 16)
                
                // Price Summary
                VStack(spacing: 12) {
                    HStack {
                        Text("보유 포인트")
                            .font(CustomFont.custom(size: 14))
                            .foregroundColor(Color(hexCode: "4D4D4D"))
                        
                        Spacer()
                        
                        Text("\(userPoints)P")
                            .font(CustomFont.custom(size: 14))
                            .foregroundColor(Color(hexCode: "4D4D4D"))
                    }
                    
                    HStack {
                        Text("총 구매 금액")
                            .font(CustomFont.custom(size: 14))
                            .foregroundColor(Color(hexCode: "4D4D4D"))
                        
                        Spacer()
                        
                        Text("-\(totalPrice)P")
                            .font(CustomFont.custom(size: 14))
                            .foregroundColor(Color(hexCode: "FF0000"))
                    }
                    
                    Rectangle()
                        .fill(Color(hexCode: "E6E6E6"))
                        .frame(height: 1)
                    
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
                
                // Warning message if not enough points
                if !canPurchase {
                    Text("포인트가 부족합니다")
                        .font(CustomFont.custom(size: 12))
                        .foregroundColor(Color(hexCode: "FF0000"))
                        .padding(.top, 8)
                }
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
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
                    
                    Button(action: {
                        if canPurchase {
                            onPurchase()
                            isPresented = false
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
                .padding(.top, 20)
                .padding(.bottom, 24)
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
}
