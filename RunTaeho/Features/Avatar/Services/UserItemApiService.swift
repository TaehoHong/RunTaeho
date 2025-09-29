//
//  ItemApiService.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/5/25.
//

import Foundation

class UserItemApiService {
    
    static let shared = UserItemApiService()
    private let HttpClient = HTTPClient.shared
    
    private init() {}
    
    
    func purchaseItem(itemIds:[Int]) async throws {
        return try await HttpClient.post(
            urlPath: APIPath.UserItem.post,
            body: ItemIds(itemIds: itemIds)
        )
    }
}
