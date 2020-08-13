//
//  Analytics.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public enum Activation {
    case `default`
    case custom(() -> Void)
    case none
}

/// protocol-adapter that provides an ability to send events to some analytics service
public protocol Analytics {
    /// Sends the event instance to the analytics service
    ///
    /// - Parameters:
    ///    - event: the event that should be sent to the analytics service
    func log(_ event: Event)

    /// Sends the event with provided name and params dictionaty to the analytics service
    ///
    /// - Parameters:
    ///    - name: the name of event that should be sent to the analytics service
    ///    - params: the dictionary of event params that should be sent to the analytics service
    func logEvent(with name: String, params: [String: AnyCodable])
    /// Calls `activationHandler` if specified
    func activate()
}

extension Analytics {

    public func logEvent(with name: String, params: [String: AnyCodable] = [:]) {
        log(Event(name: name, params: params))
    }
    public func activate() {
    }
}
