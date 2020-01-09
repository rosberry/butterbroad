//
//  ButterBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public final class Butter: Analytics {

    public var requestDelay = 0.25
    private lazy var dependencies: HasStorageService = Services
    private var eventsQueueTimer: Timer?
    private let broads: [Analytics]

    private var queue: [Event] {
        get {
            dependencies.storageService.events
        }
        set {
            dependencies.storageService.events = newValue
        }
    }

    // MARK: - Lifecycle

    /// ButterBroad initializer that creates an instance with list of provided analytics plugins (broads)
    ///
    /// - Parameters:
    ///    - broads: list of initialized analytics plugins

    public convenience init(broads: Analytics...) {
        self.init(broads: broads)
    }

    /// ButterBroad initializer that creates an instance with list of provided analytics plugins (broads)
    ///
    /// - Parameters:
    ///    - broads: array of initialized analytics plugins

    public init(broads: [Analytics]) {
        self.broads = broads
        NSSetUncaughtExceptionHandler { _ in
            Services.storageService.save()
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(prepareForBackground),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
       NotificationCenter.default.addObserver(self,
                                              selector: #selector(prepareForBackground),
                                              name: UIApplication.didEnterBackgroundNotification,
                                              object: nil)
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(prepareForForeground),
                                             name: UIApplication.willEnterForegroundNotification,
                                             object: nil)
    }

    deinit {
        stopSending()
        NotificationCenter.default.removeObserver(self)
    }

    /// Sends the event to the list of provided analytics plugins
    ///
    /// Note that butterbroad does not send an event immediately
    /// Instead of that it await `requestDelay` and sends all awaiting events
    /// All events cached to the device storage to make sure that all of them
    /// will be sent if app could not send them at the time by some reason (killed, crashed, etc.)
    ///
    /// - Parameters:
    ///    - event: the event that should be sent to the list of analytics plugins

    public func log(_ event: Event) {
        putIntoQueue(event)
    }

    // MARK: - Private

    private func putIntoQueue(_ event: Event) {
        queue.append(event)
        startSending()
    }

    @objc private func handleEventsQueue() {
        guard dependencies.storageService.events.isEmpty == false else {
            eventsQueueTimer?.invalidate()
            eventsQueueTimer = nil
            return
        }
        let event = queue.removeFirst()
        logToBroads(event)
    }

    @objc private func prepareForBackground() {
        stopSending()
        dependencies.storageService.save()
    }

    @objc private func prepareForForeground() {
        startSending()
    }

    private func logToBroads(_ event: Event) {
        broads.forEach { broad in
            broad.log(event)
        }
    }

    private func startSending() {
        if eventsQueueTimer != nil {
            return
        }
        eventsQueueTimer = Timer.scheduledTimer(timeInterval: requestDelay,
                                                target: self,
                                                selector: #selector(handleEventsQueue),
                                                userInfo: nil,
                                                repeats: true)
    }

    private func stopSending() {
        eventsQueueTimer?.invalidate()
        eventsQueueTimer = nil
    }
}
