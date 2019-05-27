//
//  Analytics.swift
//  ButterBroad
//
//  Created by Nick Tyunin on 17/05/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

/// protocool-adapter that provides an ability to send events to some analytics service

public protocol Analytics {
    /// Sends the event instance to the analytics service
    ///
    /// - Parameters:
    ///    - event: the event that should be sent to the analytics service
    func logEvent(_ event: AnalyticsEvent)

    /// Sends the event with provided name and params dictionaty to the analytics service
    ///
    /// - Parameters:
    ///    - name: the name of event that should be sent to the analytics service
    ///    - params: the dictionary of event params that should be sent to the analytics service
    func logEvent(with name: String, params: [String: String])
}

extension Analytics {

    public func logEvent(with name: String, params: [String: String] = [:]) {
        logEvent(AnalyticsEvent(name: name, params: params))
    }
}
