//
//  AnalogBroad.swift
//  AnalogBroad
//
//  Created by Nick Tyunin on 08/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Analog
import AnyCodable

public enum SessionFilter {
    case current
    case all
}

public protocol AnalogLogger {
    func log(_ event: Analog.Event)
    func currentEventsModule() -> UIViewController
    func sessionsModule() -> UIViewController
}

public final class AnalogBroad: Analytics {

    public var activationHandler: (() -> Void)?
    public private(set) var logger: AnalogLogger

    public init(logger: AnalogLogger = Logger()) {
        self.logger = logger
    }

    public func log(_ event: ButterBroad.Event) {
        var params = [String: String]()
        event.params.forEach { key, anyCodable in
            let string = anyCodable.value as? String ?? "\(anyCodable)"
            params[key] = string
        }
        logger.log(.init(title: event.name, parameters: params))
    }
}

extension Logger: AnalogLogger {
}
