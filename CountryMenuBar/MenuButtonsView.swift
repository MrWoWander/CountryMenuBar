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
        if viewModel.model != .empty {
            Menu("Info") {
                Text(ip)
                Text(country)
                Text(regiont)
                Text(city)
            }
        }
        Button("Update") {
            viewModel.refreshData()
        }
        Button("Close") {
            NSApp.terminate(nil)
        }
    }
}

private extension MenuButtonsView {
    var ip: String {
        String(format: "IP: %@", viewModel.model.ip)
    }

    var country: String {
        String(format: "Country: %@", viewModel.model.country)
    }

    var regiont: String {
        String(format: "Region: %@", viewModel.model.region)
    }

    var city: String {
        String(format: "City: %@", viewModel.model.city)
    }
}
