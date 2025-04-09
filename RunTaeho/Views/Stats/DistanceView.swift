//
//  DistanceView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct DistanceView: View {
    let distance: Double
    
    private var distanceText: String {
        String(format: "%.2fkm", distance)
    }
    
    var body: some View {
        Text(distanceText)
            .font(RunTaehoFont.distance)
            .frame(width: 194, height: 57)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }
}