//
//  SwiftyCryptoApp.swift
//  SwiftyCrypto
//
//  Created by Łukasz Stachnik on 15/07/2021.
//

import SwiftUI

@main
struct SwiftyCryptoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
