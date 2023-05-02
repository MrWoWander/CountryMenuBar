//
//  CountryMenuBarViewModel.swift
//  VPNMenuBar
//
//  Created by Mikhail Ivanov on 29.04.23.
//

import SwiftUI

final class CountryMenuBarViewModel: ObservableObject {

    @MainActor
    @Published var statusText = State.loading.text
    @MainActor
    @Published var model: Model?

    private let queryFields = Model.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    private lazy var urlPath = "http://ip-api.com/json?fields=\(queryFields)"
    private var asyncTimer: AsyncTimer?

    init() {
        Task { [weak self] in
            await self?.refreshInfo()
        }
    }

    func refreshInfo() async {
        asyncTimer?.cancel()
        await MainActor.run {
            model = nil
            statusText = State.loading.text
        }
        await refreshData()
        startTimer()
    }

    deinit {
        asyncTimer?.cancel()
    }
}

private extension CountryMenuBarViewModel {
    func refreshData() async {
        guard let model = await getCountry() else {
            await MainActor.run {
                self.model = nil
                statusText = State.error.text
            }
            return
        }
        await MainActor.run {
            guard self.model != model else { return }
            self.model = model
            statusText = String(format: "%@: %@", model.countryCode, getUnicodeFlag(model.countryCode))
        }
    }

    func startTimer() {
        let asyncTimer = AsyncTimer(withTimeInterval: .seconds(Constants.defaultTime), repeats: true) { [weak self] timer in
            guard let self else {
                timer.cancel()
                return
            }
            await self.refreshData()
        }
        self.asyncTimer = asyncTimer
    }

    func getCountry() async -> Model? {
        guard let url = URL(string: urlPath) else { return nil }
        let urlRequest = URLRequest(url: url)
        guard let data = try? await URLSession.shared.data(for: urlRequest).0,
              let model = try? JSONDecoder().decode(Model.self, from: data)
        else { return nil }
        return model
    }

    func getUnicodeFlag(_ countryCode: String) -> String {
        countryCode
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
}

extension CountryMenuBarViewModel {
    struct Model: Decodable, Equatable {
        let ip: String
        let country: String
        let countryCode: String
        let region: String
        let city: String

        enum CodingKeys: String, CodingKey, CaseIterable {
            case ip = "query"
            case country
            case countryCode
            case region
            case city
        }
    }
}

private extension CountryMenuBarViewModel {
    enum State: String {
        case loading = "🏳️"
        case error = "🏴‍☠️"
    }
}

private extension CountryMenuBarViewModel {
    enum Constants {
        static let defaultTime: TimeInterval = 120
    }
}

extension CountryMenuBarViewModel.State {
    var text: String {
        switch self {
        case .loading:
            return String(format: "Loading: %@", rawValue)
        case .error:
            return String(format: "Error: %@", rawValue)
        }
    }
}
