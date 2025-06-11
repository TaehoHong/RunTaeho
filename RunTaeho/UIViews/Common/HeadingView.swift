//
//  HeadingView.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/2/25.
//

import Foundation
import SwiftUI


struct HeadingView: View {
    
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 중앙 제목
            Text(title)
                .font(CustomFont.custom(size: 24))
                .foregroundColor(.black)
            
            // 왼쪽 뒤로가기 버튼
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(CustomFont.custom(size: 20))
                        .foregroundColor(.black)
                }
                .padding(.leading, 15)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}
