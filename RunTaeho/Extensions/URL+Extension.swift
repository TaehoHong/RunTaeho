//
//  URL+Extension.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/5/25.
//

import Foundation

extension URL {
    
    static func makeForStringEndpoint(_ endpoint: String) -> String {
        URL(string: "http://localhost:8080/\(endpoint)")!.absoluteString
    }
    
}
