//
//  ShoeViewModel.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/28/25.
//

import Foundation

struct ShoeViewModel: Identifiable {
    let id: Int
    let brand: String
    let model: String
    let targetDistance: Int?
    let totalDistance: Int
    let isMain: Bool
    var isAchieved: Bool
    let imageSystemName: String = "shoeprints.fill"
    
    var displayName: String {
        "\(brand) \(model)"
    }
    
    var formattedDistance: String {
        String(format: "총 누적 거리 %.2fkm", Double(totalDistance)/1000.0)
    }
    
    
    
    init(shoe: Shoe) {
        self.id = shoe.id
        self.brand = shoe.brand
        self.model = shoe.model
        self.targetDistance = shoe.targetDistance
        self.totalDistance = shoe.totalDistance
        self.isMain = shoe.isMain
        self.isAchieved = !shoe.isEnabled
    }

}
