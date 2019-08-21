//
//  AnalogBroad.swift
//  AnalogBroad
//
//  Created by Nick Tyunin on 08/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Analog

public enum SessionFilter {
    case current
    case all
}

public final class AnalogBroad: Analytics {
    
    private lazy var logger: Logger = .init()
    
    public init() {
    }

    public func log(_ event: ButterBroad.Event) {
        logger.log(.init(title: event.name, parameters: event.params))
    }
    
    public func module(for filter: SessionFilter) -> UIViewController {
        switch filter {
        case .current:
            return logger.currentEventsModule()
        default:
            return logger.sessionsModule()
        }
    }
}
