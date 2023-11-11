//
//  View+NavigationBackwardButton.swift
//  AuthenticationDemo
//
//  Created by kaito-seita on 2023/09/27.
//

import SwiftUI

struct CustomBackwardButton: ViewModifier {
    
    @Environment(\.dismiss) var dismiss
    
    private let edgeWidth: Double = 50
    private let baseDragWidth: Double = 40

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .navigationBarBackButtonHidden(true)
            .gesture (
                DragGesture().onChanged { value in
                    if value.startLocation.x < edgeWidth && value.translation.width > baseDragWidth {
                        dismiss()
                    }
                }
            )
            .overlay {
                VStack {
                    HStack {
                        Button(
                            action: {
                                dismiss()
                            }, label: {
                                Image(systemName: "arrow.uturn.backward")
                            }
                        )
                        .tint(.black)
                        .padding()
                        .background(
                            Circle()
                                .foregroundColor(.white)
                        )
                        Spacer()
                    }.padding(.leading, 20)
                    Spacer()
                }.padding(.top, 20)
            }
    }
}

extension View {
    
    func customBackwardButton() -> some View {
        self.modifier(CustomBackwardButton())
    }
}
