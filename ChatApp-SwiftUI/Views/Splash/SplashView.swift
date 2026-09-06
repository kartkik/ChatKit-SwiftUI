//
//  SplashView.swift
//  ChatApp-SwiftUI
//
//  Created by twixx  on 04/09/26.
//


import SwiftUI

struct SplashView: View {

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)

                Text("ChatKit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("AI-powered conversations")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
        .preferredColorScheme(.dark)
}
