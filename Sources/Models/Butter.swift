//
//  ButterBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Darwin

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
        activationHandler = { [weak self] in
            guard let self = self else {
                return
            }

            self.trap(signals: [.abrt, .quit, .kill, .term]) { _ in
                Services.storageService.save() // Context is unavailable here, could not use dependencies
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
            self.startSending() // Check queue from last session

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


    private func trap(signal: Signal, action: @escaping @convention(c) (Int32) -> ()) {
        var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
        _ = withUnsafePointer(to: &signalAction) { actionPointer in
            UserDefaults.standard.set("__signal_\(signal.rawValue)", forKey: "__last_captured_signal")
            sigaction(signal.rawValue, actionPointer, nil)
        }
    }

    private func trap(signals: [Signal], action: @escaping SignalActionHandler) {
        signals.forEach { signal in
            trap(signal: signal, action: action)
        }
    }
}
