//
//  AddShoeDto.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/10/25.
//

import Foundation


struct AddShoeDto: Codable{
    let brand: String
    let model: String
    let targetDistance: Int
    var isMain: Bool
}
