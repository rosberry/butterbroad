//
//  Butter.swift
//  ButterBroadExample
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import AnalogBroad
//import FaceBookBroad
//import CrashlyticsBroad

extension Butter {
    static let analog: AnalogBroad = .init()
//    static let facebook: FaceBookBroad = .init()
//    static let crashlytics: CrashlyticsBroad = .init()
    static let common: Butter = .init(broads: [analog])//, facebook, crashlytics)
}
