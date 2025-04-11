//
//  BPMView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct BPMView: View {
    let bpm: Int
    
    private var bpmText: String {
        String(format: "%02d", bpm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("BPM")
                .font(CustomFont.stats())
            Text(bpmText)
                .font(CustomFont.stats())
        }
        .frame(width: 105, height: 45)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
    }
}
