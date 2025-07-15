//
//  Item.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/5/25.
//

import Foundation

struct Item: Codable {
    
    let id: Int
    let name: String
    let itemType: ItemTypeDto
    let filePath: String
    let unityFilePath: String
    var isOwned: Bool
    let point: Int
    
}


struct ItemTypeDto : Codable {
    let id: Int
    let name: String
}
