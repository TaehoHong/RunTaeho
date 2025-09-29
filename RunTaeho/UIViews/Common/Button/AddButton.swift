//
//  AddButton.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/11/25.
//

import Foundation
import SwiftUI

struct AddButton: View {
    
    let action: () -> Void
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color(hexCode: "7BE87B"))
                    .frame(width: 24, height: 24)
                
                // + 모양 만들기
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hexCode: "382F2F"))
                        .frame(width: 2, height: 12)
                    
                    Rectangle()
                        .fill(Color(hexCode: "382F2F"))
                        .frame(width: 12, height: 2)
                        .offset(y: -6)
                }
            }
        }
        .padding(.trailing, 25)
    }
}

