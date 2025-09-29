//
//  PurchaseViewModel.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/18/25.
//

import Foundation

class PurchaseViewModel: ObservableObject {
    @Published var items: [PurchaseItemViewModel]
    @Published var userPoints: Int
    @Published var isPurchasing: Bool = false
    
    init(items: [PurchaseItemViewModel], userPoints: Int) {
        self.items = items
        self.userPoints = userPoints
    }
    
    var totalPrice: Int {
        items.reduce(0) { $0 + $1.price }
    }
    
    var remainingPoints: Int {
        userPoints - totalPrice
    }
    
    var canPurchase: Bool {
        remainingPoints >= 0 && !isPurchasing
    }
    
    func processPurchase(completion: @escaping () -> Void) {
        isPurchasing = true
        // 실제 구매 로직이 여기에 구현됩니다
        completion()
        isPurchasing = false
    }
}
