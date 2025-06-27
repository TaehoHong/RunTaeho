//
//  PointHistoryViewModel.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/27/25.
//

import Foundation

struct PointHistoryViewModel: Identifiable {
    
    let id: Int
    let isPositive: Bool
    let title: String
    
    private let point: Int
    private let date: Date
    
    var formattedPoint: String {
        return "\(isPositive ? "+" : "-")\(point)P"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.string(from: date)
    }
    
    
    init(pointHistory: PointHistory) {
        self.id = pointHistory.id
        self.point = abs(pointHistory.point)
        self.isPositive = pointHistory.point > 0
        self.title = pointHistory.pointType
        self.date = Date(timeIntervalSince1970: Double(pointHistory.createdTimestamp))
        
    }
}
