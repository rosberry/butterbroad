//
//  Butter.swift
//  ButterBroadExample
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad

extension Butter {
    static let analog: AnalogBroad = .init()
    static let facebook: FacebookBroad = .init()
    static let firebase: FirebaseBroad = .init()
    static let common: Butter = .init(broads: analog, facebook, firebase)
}
