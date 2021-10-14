//
//  FirebaseBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Firebase

final public class FirebaseBroad: ButterBroad.Analytics {

    private let activation: Activation

    /// Creates `FirebaseBroad` instance with provided activation type
    ///
    /// - parameter activation: specifies an action for the Facebook that should be aplied on `FirebaseBroad`activation. The default value `.none` assumes that
    /// no action required and `FirebaseApp.configure` will called on the user side. The value `.default` assumes that `FirebaseApp.configure()` will called
    /// on the `FirebaseBroad` side. The value `.custom` assumes that user provided specific activation will called on the `FirebaseBroad` side.
    public init(activation: Activation = .none) {
        self.activation = activation
    }

    public func log(_ event: Event) {
        var params: [String: Any] = [:]
        event.params.forEach { (key: String, anyCodable: AnyCodable) in
            params[key] = anyCodable.value
        }
        Firebase.Analytics.logEvent(event.name, parameters: params)
    }

    public func activate() {
        switch activation {
        case .custom(let activationHandler):
            activationHandler()
        case .default:
            FirebaseApp.configure()
        case .none:
            return
        }
    }
}
