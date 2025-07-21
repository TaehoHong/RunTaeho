//
//  Avatar.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/21/25.
//

import Foundation

class Avatar: Codable {
    let id: Int
    let userId: Int
    let isMain: Bool
    let avatarItems: [Item]
}
