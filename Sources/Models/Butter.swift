//
//  ButterBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Darwin

// MARK: - File operations
// File operation methods should be available without context in case of abnormal app termination

fileprivate var events: [Event] = []

fileprivate func storageURL() -> URL? {
    return storageDirectoryURL()?.appendingPathComponent(".butterbroad")
}

fileprivate func storageDirectoryURL() -> URL? {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

fileprivate func unloadEventsFromDisk() {
    guard let url = storageURL(),
        let data = try? Data(contentsOf: url),
        let loadedEvents = try? JSONDecoder().decode([Event].self, from: data) else {
        return
    }
    try? FileManager.default.removeItem(at: url)
    events = loadedEvents
}

fileprivate func saveEventsToDisk() {
    guard let url = storageURL(),
        let data = try? JSONEncoder().encode(events) else {
        return
    }
    try? data.write(to: url)
}

// MARK: - Butter
public final class Butter: Analytics {

    private typealias SignalActionHandler = @convention(c)(Int32) -> Void

    private enum Signal {
        case hup
        case int
        case quit
        case abrt
        case kill
        case alrm
        case term
        case pipe
        case user(Int32)

        var rawValue: Int32 {
            switch self {
            case .hup:
                return Int32(SIGHUP)
            case .int:
                return Int32(SIGINT)
            case .quit:
                return Int32(SIGQUIT)
            case .abrt:
                return Int32(SIGABRT)
            case .kill:
                return Int32(SIGKILL)
            case .alrm:
                return Int32(SIGALRM)
            case .term:
                return Int32(SIGTERM)
            case .pipe:
                return Int32(SIGPIPE)
            case .user(let value):
                return value
            }
        }
    }

    public var requestDelay = 0.25
    public var activationHandler: (() -> Void)?
    private var eventsQueueTimer: Timer?
    private let broads: [Analytics]

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
        unloadEventsFromDisk()
        activationHandler = { [weak self] in
            guard let self = self else {
                return
            }

            self.trap(signals: [.abrt, .quit, .kill, .term]) { _ in
                saveEventsToDisk()
            }
    
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.prepareForBackground),
                                                 name: UIApplication.willTerminateNotification,
                                                 object: nil)
            NotificationCenter.default.addObserver(self,
                                                selector: #selector(self.prepareForBackground),
                                                name: UIApplication.didEnterBackgroundNotification,
                                                object: nil)
            NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.prepareForForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
            self.handleEventsQueue() // Check queue from last session
            self.startSending()

            self.broads.forEach { broad in
                broad.activationHandler?()
            }
        }
    }

    deinit {
        stopSending()
        NotificationCenter.default.removeObserver(self)
    }

    /// Sends the event to the list of provided analytics plugins
    ///
    /// Note that butterbroad does not send an event immediately
    /// Instead of that it await `requestDelay` and sends all awaiting events
    ///
    /// - Parameters:
    ///    - event: the event that should be sent to the list of analytics plugins

    public func log(_ event: Event) {
        events.append(event)
        startSending()
    }

    // MARK: - Private

    @objc private func handleEventsQueue() {
        guard events.isEmpty == false else {
            eventsQueueTimer?.invalidate()
            eventsQueueTimer = nil
            return
        }
        let event = events.removeFirst()
        logToBroads(event)
    }

    @objc private func prepareForBackground() {
        stopSending()
        saveEventsToDisk()
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


    private func trap(signal: Signal, action: @escaping SignalActionHandler) {
        var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
        _ = withUnsafePointer(to: &signalAction) { actionPointer in
            sigaction(signal.rawValue, actionPointer, nil)
        }
    }

    private func trap(signals: [Signal], action: @escaping SignalActionHandler) {
        signals.forEach { signal in
            trap(signal: signal, action: action)
        }
    }
}
