//
//  ItemApiService.swift
//  RunTaeho
//
//  Created by Hong Taeho on 7/5/25.
//

import Foundation

class ItemApiService {
    
    static let shared = ItemApiService()
    private let HttpClient = HTTPClient.shared
    
    private init() {}
    
    
    func getItems(cursor: Int? = nil, itemTypeId:Int, excludeMyItems:Bool=false) async throws -> CursorResult<Item> {
        return try await HttpClient.get(
            urlPath: APIPath.Item.list,
            responseType: CursorResult<Item>.self
        )
    }
}
