//
//  TokenDto.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/5/25.
//


class TokenDto: Codable {
    
    let userId: Int
    let accessToken: String
    let refreshToken: String
    
    init(userId: Int, accessToken: String, refreshToken: String) {
        self.userId = userId
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
