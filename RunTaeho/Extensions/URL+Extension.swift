//
//  URL+Extension.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/5/25.
//

import Foundation

extension URL {
    
    static var baseURL: String {
        guard let host = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
              fatalError("API Host not configured")
        }
        return host
    }
    
    static func makeForStringEndpoint(_ endpoint: String) -> String {
        URL(string: baseURL + "/\(endpoint)")!.absoluteString
    }
    
}
