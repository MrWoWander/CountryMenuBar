//
//  CountryMenuBarApp.swift
//  VPNMenuBar
//
//  Created by Mikhail Ivanov on 29.04.23.
//

import SwiftUI

@main
struct CountryMenuBarApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = CountryMenuBarViewModel()
    var body: some Scene {
        MenuBarExtra {
            MenuButtonsView(viewModel: viewModel)
        } label: {
            Text(viewModel.countryCode)
        }
    }
}
