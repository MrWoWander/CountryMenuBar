//
//  CountryMenuBarViewModel.swift
//  VPNMenuBar
//
//  Created by Mikhail Ivanov on 29.04.23.
//

import SwiftUI
import Combine

final class CountryMenuBarViewModel: ObservableObject {

    @Published var statusText = Icon.global.rawValue
    @Published var model = Model.empty

    private lazy var urlPath = "http://ip-api.com/json?fields=\(queryFields)"
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
        model = .empty
        statusText = String(format: "Loading: %@", Icon.loading.rawValue)
        getCountry()
            .sink(receiveValue: { [weak self] model in
                self?.model = model
                if model.countryCode.isEmpty {
                    self?.statusText = String(format: "Error: %@", Icon.error.rawValue)
                } else {
                    self?.statusText = String(format: "%@: %@", model.countryCode, Icon.getUnicodeFlag(model.countryCode))
                }
            })
            .store(in: &cancabledSet)
    }
}

private extension CountryMenuBarViewModel {
    var queryFields: String {
        Model.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    }

    func startTimer() {
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

    func getCountry() -> AnyPublisher<Model, Never> {
        guard let url = URL(string: urlPath) else { return Just(Model.empty).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Model.self, decoder: JSONDecoder())
            .replaceError(with: .empty)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension CountryMenuBarViewModel {
    struct Model: Decodable, Equatable {
        let ip: String
        let country: String
        let countryCode: String
        let region: String
        let city: String

        static let empty = Model(ip: "", country: "", countryCode: "", region: "", city: "")

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
