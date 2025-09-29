//
//  UserService.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/20/25.
//

import Foundation


class UserService {
    
    public static let shared = UserService()
    private let userApiService = UserAPIService.shared
     
    private init() {}
    
    
    func getUserDatadto(accessToken: String) async throws -> UserDataDto {
        return try await userApiService.getUserDataDto(accessToken);
    }
    
}
