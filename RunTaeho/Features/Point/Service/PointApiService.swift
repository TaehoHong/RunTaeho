//
//  PointApiService.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/26/25.
//

import Foundation

class PointApiService {
    
    static let shared = PointApiService()
    private let httpClient = HTTPClient.shared
    private let userStateManager = UserStateManager.shared
    
    private init() {}
    
    
    func getPointHistories(cursor: Int?=nil, isEarned: Bool?=nil, startCreatedDatetime:Date?=nil) async throws -> CursorResult<PointHistory> {
        let headers: [String: String]?
        
        if let authToken = userStateManager.authToken {
            headers = ["Authorization": "Bearer \(authToken)"]
        } else {
            headers = nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            httpClient.get(
                urlPath: APIPath.Point.histories,
                headers: headers,
                requestParam: makeRequestParam(cursor: cursor, isEarned: isEarned, startCreatedDatetime: startCreatedDatetime, size: 30),
                responseType: CursorResult<PointHistory>.self
            ) { result in
                switch result {
                case .success(let pointHistory):
                    print("UserInfo received: \(pointHistory)")
                    continuation.resume(returning: pointHistory)
                case .failure(let error):
                    print("Error occurred: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func makeRequestParam(cursor: Int?=nil, isEarned: Bool?=nil, startCreatedDatetime:Date?=nil, size: Int?=nil) -> RequestParam {
        
        
        var params: [String: String] = [:]
        if let cursor = cursor {
            params["cursor"] = String(cursor)
        }
        if let size = size {
            params["size"] = String(size)
        }
        if let isEarned = isEarned {
            params["isEarned"] = String(isEarned)
        }
        if let startCreatedDatetime = startCreatedDatetime {
            params["startCreatedTimestamp"] = String(Int(startCreatedDatetime.timeIntervalSince1970))
        }
        
        return RequestParam(params: params)
    }
}
