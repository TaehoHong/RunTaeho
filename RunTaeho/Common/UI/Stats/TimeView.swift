//
//  TimeView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct TimeView: View {
    let hours: Int
    let minutes: Int
    let seconds: Int
    
    private var timeText: String {
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("시간")
                .font(CustomFont.stats())
            Text(timeText)
                .font(CustomFont.stats())
        }
        // .frame(width: 105, height: 52)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}
