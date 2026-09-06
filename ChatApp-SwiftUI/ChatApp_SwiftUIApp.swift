//
//  ChatApp_SwiftUIApp.swift
//  ChatApp-SwiftUI
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI
import ChatKit

@main
struct ChatApp_SwiftUIApp: App {

    @State private var showSplash = true
    @State private var chatScreenVM = ChatScreenViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView { showSplash = false }
                        .transition(.opacity)
                } else {
                    AppChatScreen(viewModel: chatScreenVM)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showSplash)
            .preferredColorScheme(.dark)
        }
    }
}
