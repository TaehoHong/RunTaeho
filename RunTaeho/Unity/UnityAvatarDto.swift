//
//  UnityAvatarDto.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/17/25.
//

import Foundation


class UnityAvatarDto: Codable {
    let name: String
    let part: String
    let itemPath: String
    
    init(name: String, part: String, itemPath: String) {
        self.name = name
        self.part = part
        self.itemPath = itemPath
    }
}

// Unity에서 기대하는 리스트 래퍼 구조
class UnityAvatarDtoList: Codable {
    let list: [UnityAvatarDto]
    
    init(list: [UnityAvatarDto]) {
        self.list = list
    }
}
