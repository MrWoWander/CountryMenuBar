//
//  MenuButtonsView.swift
//  VPNMenuBar
//
//  Created by Mikhail Ivanov on 29.04.23.
//

import SwiftUI

struct MenuButtonsView: View {
    @ObservedObject private var viewModel: CountryMenuBarViewModel

    init(viewModel: CountryMenuBarViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button("Update info") {
            viewModel.refreshData()
        }
        Button("Close") {
            NSApp.terminate(nil)
        }
    }
}
