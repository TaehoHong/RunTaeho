//
//  AddShoeDto.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/10/25.
//

import Foundation


struct PatchShoeDto: Codable {
    let id: Int
    let brand: String?
    let model: String?
    let targetDistance: Int?
    let isMain: Bool?
    let isEnabled: Bool?
    let isDeleted: Bool?
    
    init(id: Int,
         brand: String?=nil,
         model: String?=nil,
         targetDistance: Int?=nil,
         isMain: Bool?=nil,
         isEnabled: Bool?=nil,
         isDeleted: Bool?=nil
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.targetDistance = targetDistance
        self.isMain = isMain
        self.isEnabled = isEnabled
        self.isDeleted = isDeleted
    }
}
