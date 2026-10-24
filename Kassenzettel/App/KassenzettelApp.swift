//
//  KassenzettelApp.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

@main
struct KassenzettelApp: App {
    @State private var auth = AuthModel()


    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .task { await auth.start() }
        }
    }
}
