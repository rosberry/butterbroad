//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad
import FBSDKCoreKit

public final class FacebookBroad: Analytics {

    public var activationHandler: (() -> Void)? = {
        AppEvents.activateApp()
    }

    public init() {
    }

    public func log(_ event: Event) {
        AppEvents.logEvent(AppEvents.Name(rawValue: event.name), parameters: event.params)
    }
}
