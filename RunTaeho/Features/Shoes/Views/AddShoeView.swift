import SwiftUI

struct AddShoeView: View {
    @StateObject private var viewModel = AddShoeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (AddShoeDto) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hexCode: "FAFAFA")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 헤더
                    HeadingView(title: "신발 추가")
                    
                    VStack(spacing: 20) {
                        // 브랜드 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("브랜드")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("", text: $viewModel.brand)
                                .placeholder(when: viewModel.brand.isEmpty) {
                                    Text("나이키, 아디다스, 뉴발란스...")
                                        .font(CustomFont.custom(size: 14))
                                        .foregroundColor(Color(hexCode: "B3B3B3"))
                                }
                                .font(CustomFont.custom(size: 14))
                                .padding(.horizontal, 15)
                                .frame(height: 45)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hexCode: "E6E6E6"), lineWidth: 1)
                                )
                        }
                        
                        // 모델명 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("모델명")
                                .font(CustomFont.custom(size: 16))
                                .foregroundColor(.black)
                            
                            TextField("", text: $viewModel.model)
                                .placeholder(when: viewModel.model.isEmpty) {
                                    Text("에어 줌 페가수스 40, 울트라부스트 22...")
                                        .font(CustomFont.custom(size: 14))
                                        .foregroundColor(Color(hexCode: "B3B3B3"))
                                }
                                .font(CustomFont.custom(size: 14))
                                .padding(.horizontal, 15)
                                .frame(height: 45)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hexCode: "E6E6E6"), lineWidth: 1)
                                )
                        }
                        
                        // 목표 거리 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("목표 거리 (선택)")
                                .font(CustomFont.custom(size: 16))
                                .foregroundColor(.black)
                            
                            TextField("", text: $viewModel.targetDistance)
                                .placeholder(when: viewModel.targetDistance.isEmpty) {
                                    Text("500, 800, 1000 (km)")
                                        .font(CustomFont.custom(size: 14))
                                        .foregroundColor(Color(hexCode: "B3B3B3"))
                                }
                                .font(CustomFont.custom(size: 14))
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 15)
                                .frame(height: 45)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hexCode: "E6E6E6"), lineWidth: 1)
                                )
                        }
                        
                        Spacer()
                        
                        // 버튼들
                        HStack(spacing: 20) {
                            // 취소 버튼
                            Button(action: {
                                dismiss()
                            }) {
                                Text("취소")
                                    .font(CustomFont.custom(size: 16))
                                    .foregroundColor(Color(hexCode: "4D4D4D"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(hexCode: "E6E6E6"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hexCode: "CCCCCC"), lineWidth: 1)
                                    )
                            }
                            
                            // 저장 버튼
                            Button(action: {
                                let newShoe = viewModel.createShoe()
                                onSave(newShoe)
                                dismiss()
                            }) {
                                Text("저장")
                                    .font(CustomFont.custom(size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(viewModel.isFormValid ? Color(hexCode: "7AE87A") : Color.gray.opacity(0.3))
                            }
                            .disabled(!viewModel.isFormValid)
                        }
                    }
                    .padding(.horizontal, 33)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// TextField placeholder extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
