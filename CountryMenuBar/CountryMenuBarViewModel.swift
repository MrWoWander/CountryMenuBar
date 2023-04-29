//
//  CountryMenuBarViewModel.swift
//  VPNMenuBar
//
//  Created by Mikhail Ivanov on 29.04.23.
//

import SwiftUI
import Combine

final class CountryMenuBarViewModel: ObservableObject {

    @Published var countryCode = Icon.global.rawValue

    private let urlPath = "http://ip-api.com/json"
    private var timer: Timer?
    private let defaultTime: TimeInterval = 120
    private var cancabledSet: Set<AnyCancellable> = []

    init() {
        refreshData()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func refreshData() {
        countryCode = String(format: "Loading: %@", Icon.loading.rawValue)
        getCountry()
            .assign(to: \.countryCode, on: self)
            .store(in: &cancabledSet)
    }
}

private extension CountryMenuBarViewModel {
    func startTimer() {
        var count = 0
        let timer = Timer.scheduledTimer(withTimeInterval: defaultTime, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            self.refreshData()
        }
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    func getCountry() -> AnyPublisher<String, Never> {
        guard let url = URL(string: urlPath) else { return Just(String()).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Model.self, decoder: JSONDecoder())
            .map { String(format: "%@: %@", $0.countryCode, Icon.getUnicodeFlag($0.countryCode)) }
            .replaceError(with: String(format: "Error: %@", Icon.error.rawValue))
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

private extension CountryMenuBarViewModel {
    struct Model: Decodable {
        var countryCode: String
    }

    enum Icon: String {
        case global = "🌍"
        case loading = "🏳️"
        case error = "⚠️"
    }
}

extension CountryMenuBarViewModel.Icon {
    static func getUnicodeFlag(_ countryCode: String) -> String {
        countryCode
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
}
