//
//  StorageService.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

final class StorageService: StorageServiceProtocol {

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
        guard _events.isEmpty, let url = storageURL(), let events = NSArray(contentsOf: url) as? [Event] else {
            return _events
        }
        _events = events
        try? FileManager.default.removeItem(at: url)
        return events
    }

    private func save(_ events: [Event]) {
        _events = events
        guard let url = storageURL() else {
            return
        }
        (events as NSArray).write(to: url, atomically: true)
    }

    private func storageURL() -> URL? {
        return storageDirectoryURL()?.appendingPathComponent("__analytics.tmp")
    }

    private func storageDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
