//
//  FirebaseBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Firebase

final public class FirebaseBroad: ButterBroad.Analytics {

    static let defaultActivation: (() -> Void)? = {
        FirebaseApp.configure()
    }

    public var activationHandler: (() -> Void)?

    public init(with activationHandler: (() -> Void)? = nil) {
        self.activationHandler = activationHandler
    }


    public func log(_ event: Event) {
        Firebase.Analytics.logEvent(event.name, parameters: event.params)
    }
}
