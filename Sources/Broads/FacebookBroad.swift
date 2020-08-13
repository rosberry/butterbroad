//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad
import FBSDKCoreKit

public final class FacebookBroad: Analytics {

    private let activation: Activation

    /// Creates `FacebookBroad` instance with provided activation type
    ///
    /// - parameter activation: specifies an action for the Facebook that should be aplied on `ButterBroad`activation. The default value `.none` assumes that
    /// no action required and `AppEvents.activateApp` will called on the user side. The value `.default` assumes that `AppEvents.activateApp()` will called
    /// on the `FacebookBroad` side. The value `.custom` assumes that user provided specific activation will called on the `FacebookBroad` side.
    public init(activation: Activation = .none) {
        self.activation = activation
    }

    public func log(_ event: Event) {
        AppEvents.logEvent(AppEvents.Name(rawValue: event.name), parameters: event.params)
    }

    public func activate() {
        switch activation {
        case .custom(let activationHandler):
            activationHandler()
        case .default:
            AppEvents.activateApp()
        case .none:
            return
        }
    }
}
