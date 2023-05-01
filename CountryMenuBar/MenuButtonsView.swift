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
        if let model = viewModel.model {
            Menu("Info") {
                Text("IP: \(model.ip)")
                Text("Country: \(model.country)")
                Text("Region: \(model.region)")
                Text("City: \(model.city)")
            }
        }
        Button("Update") {
            Task {
                await viewModel.refreshInfo()
            }
        }
        Button("Close") {
            NSApp.terminate(nil)
        }
    }
}
