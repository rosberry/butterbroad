//
//  StorageService.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

final class StorageService: StorageServiceProtocol {

    private enum Keys {
        static let cachedEvents = "__cached_events__"
    }

    private var _events: [Event] = []

    var events: [Event] {
        get {
            return load()
        }
        set {
            _events = newValue
        }
    }

    public func save() {
        save(_events)
    }

    // MARK: - Private

    private func load() -> [Event] {
        guard _events.isEmpty,
            let data = UserDefaults.standard.data(forKey: Keys.cachedEvents),
            let events = try? JSONDecoder().decode([Event].self, from: data) else {
            return _events
        }
        UserDefaults.standard.removeObject(forKey: Keys.cachedEvents)
        _events = events
        return events
    }

    private func save(_ events: [Event]) {
        _events = events
        guard let data = try? JSONEncoder().encode(events) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Keys.cachedEvents)
    }
}
