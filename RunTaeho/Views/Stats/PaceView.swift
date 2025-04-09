//
//  PaceView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct PaceView: View {
    let minutes: Int
    let seconds: Int
    
    private var paceText: String {
        String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("페이스")
                .font(RunTaehoFont.stats)
            Text(paceText)
                .font(RunTaehoFont.stats)
        }
        .frame(width: 105, height: 45)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}