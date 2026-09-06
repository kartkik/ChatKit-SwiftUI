//
//  AppChatScreen.swift
//  ChatApp-SwiftUI
//
//  Created by twixx  on 04/09/26.
//

import SwiftUI
import ChatKit

struct AppChatScreen: View {

    @State var viewModel: ChatScreenViewModel

    var body: some View {
        ChatScreen(
            service: viewModel.service,
            config:  viewModel.config
        )
    }
}

#Preview {
    AppChatScreen(viewModel: ChatScreenViewModel())
        .preferredColorScheme(.dark)
}
