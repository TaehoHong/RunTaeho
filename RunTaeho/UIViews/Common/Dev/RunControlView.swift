//
//  RunControlView.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI
import UnityFramework

struct DevButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CustomFont.custom(size: 15))
                .foregroundColor(.white)
                .frame(width: 60, height: 32)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                .cornerRadius(4)
        }
    }
}

struct VelocityDevButtonView: View {

    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack {
            ZStack {            
                RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.95))
                .frame(width: 140, height: 44)
            
                HStack(spacing: 8) {
                    DevButton(title: "Go") {
                        Unity.shared.sendMessage("Charactor", methodName: "SetSpeed", parameter: "5")
                    }
                    
                    DevButton(title: "Stop") {
                        Unity.shared.sendMessage("Charactor", methodName: "SetSpeed", parameter: "0")
                    }
                }
            }
            Button(action: {
                viewModel.addDistance(distance: 10000.0)
            }){
                Text("거리 추가")
            }
        }
    }
}
