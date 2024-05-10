//
//  ContentView.swift
//  JokingPanda
//
//  Created by Lukas Carvajal on 10/23/23.
//

import SwiftUI
import Speech

struct BaseView: View {
    @State var authorizationsViewModel: AuthorizationsViewModel
     
    var body: some View {
        if authorizationsViewModel.isAuthorizationRequired {
            AuthorizationsView(authorizationsViewModel: authorizationsViewModel)
        }
        else {
            let viewModel = BotViewModel()
            BotView(botViewModel: viewModel)
        }
    }
}
