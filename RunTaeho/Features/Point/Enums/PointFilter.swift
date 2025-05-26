//
//  PointFilter.swift
//  RunTaeho
//
//  Created by Hong Taeho on 5/23/25.
//

import Foundation

// 포인트 필터 타입
enum PointFilter: String, CaseIterable {
    case all = "전체"
    case earned = "적립"
    case spent = "사용"
    
    var displayName: String {
        return self.rawValue
    }
}
