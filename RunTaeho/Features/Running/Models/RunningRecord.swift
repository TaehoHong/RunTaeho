//
//  RunningRecord.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/29/25.
//

import Foundation

class RunningRecord: Identifiable, Codable {
    var id: Int
    var distance: Double
    var duration: Double
    var date: Date
    
    init(distance: Double, duration: Double, date: Date = Date()) {
        self.distance = distance
        self.durationSec: Double = duration
        self.durationSec = duration
    }
}
