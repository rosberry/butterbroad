//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad
import FBSDKCoreKit

public final class FacebookBroad: Analytics {

    static let defaultActivation: (() -> Void)? = {
        AppEvents.activateApp()
    }

    public var activationHandler: (() -> Void)?

    public init(with activationHandler: (() -> Void)? = nil) {
        self.activationHandler = activationHandler
    }

    public func log(_ event: Event) {
        AppEvents.logEvent(AppEvents.Name(rawValue: event.name), parameters: event.params)
    }
}
