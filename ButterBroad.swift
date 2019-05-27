//
//  ButterBroad.swift
//  ButterBroad
//
//  Created by Nick Tyunin on 17/05/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

public final class ButterBroad: Analytics {

    private lazy var dependencies: HasStorageService = Services
    private var eventsQueueTimer: Timer?
    private let requestDelay = 0.25
    private let broads: [Analytics]

    // MARK: - Lifecycle

    /// ButterBroad initializer that creates an instance with list of provided analytics plugins (broads)
    ///
    /// - Parameters:
    ///    - broads: list of initialized analytics plugins

    init(with broads: Analytics...) {
        self.broads = broads
    }

    /// Sends the event to the list of provided analytics plugins
    ///
    /// Note that butterbroad does not send an event immediately
    /// Instead of that it await `requestDelay` and sends all awaiting events
    /// All events cached to the device storage to make sure that all of them
    /// will be sent if app could not send them at the time by some reason (killed, crashed, e.t.c.)
    ///
    /// - Parameters:
    ///    - event: the event that should be sent to the list of analytics plugins

    public func logEvent(_ event: AnalyticsEvent) {
        putIntoQueue(event)
    }

    // MARK: - Private

    private func putIntoQueue(_ event: AnalyticsEvent) {
        dependencies.storageService.events.append(event)
        if eventsQueueTimer != nil {
            return
        }
        eventsQueueTimer = Timer.scheduledTimer(timeInterval: requestDelay,
                                                target: self,
                                                selector: #selector(handleEventsQueue),
                                                userInfo: nil,
                                                repeats: true)
    }

    @objc private func handleEventsQueue() {
        guard dependencies.storageService.events.isEmpty == false else {
            eventsQueueTimer?.invalidate()
            eventsQueueTimer = nil
            return
        }
        let event = dependencies.storageService.events.remove(at: 0)
        logToBroads(event)
    }

    private func logToBroads(_ event: AnalyticsEvent) {
        broads.forEach { broad in
            broad.logEvent(event)
        }
    }
}
