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
        
        var params: [String: String] = [:]
        
        if let cursor = cursor {
            params["cursor"] = String(cursor)
        }
        
        params["itemTypeId"] = String(itemTypeId)
        
        return try await HttpClient.get(
            urlPath: APIPath.Item.list,
            requestParam: RequestParam(params: params),
            responseType: CursorResult<Item>.self
        )
    }
}
