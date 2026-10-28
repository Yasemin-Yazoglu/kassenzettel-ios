//
//  RootView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct RootView: View {
    @Environment(AuthModel.self) private var auth

    var body: some View {
        if auth.isLoading {
            ProgressView()
        } else if auth.session != nil {
            AccountHomeView()
        } else {
            DemoView()
        }
    }
}
