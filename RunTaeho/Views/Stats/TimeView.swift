//
//  TimeView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct TimeView: View {
    let minutes: Int
    let seconds: Int
    
    private var timeText: String {
        String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("시간")
                .font(RunTaehoFont.stats)
            Text(timeText)
                .font(RunTaehoFont.stats)
        }
        .frame(width: 105, height: 52)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}

