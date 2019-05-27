//
//  UserDefaults+Storage.swift
//  ButterBroad
//
//  Created by Nick Tyunin on 17/05/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

extension UserDefaults: StorageServiceProtocol {

    private enum Keys {
        static let events = "butterbroad_events"
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    var events: [AnalyticsEvent] {
        get {
            if let data = data(forKey: Keys.events),
                let events = try? UserDefaults.decoder.decode([AnalyticsEvent].self, from: data) {
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
