//
//  AsyncTimer.swift
//  CountryMenuBar
//
//  Created by Mikhail Ivanov on 02.05.23.
//

import Foundation

final class AsyncTimer {
    private var task: Task<Void, Never>?

    init(withTimeInterval: Duration, repeats: Bool, action: @escaping (AsyncTimer) async -> Void) {
        let actor = Actor(timer: self)
        task = Task.detached(priority: .background) {
            await actor.startTask(time: withTimeInterval, repeats: repeats, action: action)
        }
    }

    func cancel() {
        task?.cancel()
    }

    func isCancelled() -> Bool {
        task?.isCancelled ?? true
    }
}

private extension AsyncTimer {
    actor Actor {
        let timer: AsyncTimer

        init(timer: AsyncTimer) {
            self.timer = timer
        }

        func startTask(time: Duration, repeats: Bool, action: @escaping (AsyncTimer) async -> Void) async {
            while !Task.isCancelled {
                guard (try? await Task.sleep(for: time)) != nil else { break }
                await action(timer)
                guard repeats else { break }
            }
        }
    }
}
