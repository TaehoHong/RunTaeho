//
//  AvatarApiService.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/18/25.
//

import Foundation

class AvatarApiService {
    private let httpClient = HTTPClient.shared
    static let shared = AvatarApiService()
    
    private init() { }
    
    public func changeAvatarItems(avatarId: Int, itemIds: [Int]) async throws -> Avatar {
        return try await httpClient.put(
            urlPath: APIPath.Avatar.put(avatarId),
            body: ItemIds(itemIds: itemIds),
            responseType: Avatar.self
        )
    }
}
