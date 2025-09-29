//
//  BPMView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct BPMView: View {
    let bpm: Int
    let isFromWatch: Bool
    
    private var bpmText: String {
        String(format: "%02d", bpm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                Text("BPM")
                    .font(CustomFont.stats())
                if isFromWatch {
                    Image(systemName: "applewatch")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            Text(bpmText)
                .font(CustomFont.stats())
        }
        .frame(width: 105, height: 45)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}
