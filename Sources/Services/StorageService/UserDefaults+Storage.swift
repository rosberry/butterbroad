//
//  UserDefaults+Storage.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

extension UserDefaults: StorageServiceProtocol {

    private enum Keys {
        static let events = "butterbroad_events"
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    var events: [Event] {
        get {
            if let data = data(forKey: Keys.events),
                let events = try? UserDefaults.decoder.decode([Event].self, from: data) {
                return events
            }
            return []
        }
        set {
            if let data = try? UserDefaults.encoder.encode(newValue) {
                set(data, forKey: Keys.events)
            }
        }
    }
}
