//
//  Butter.swift
//  AnalogBroadExample
//
//  Created by Nick Tyunin on 08/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import AnalogBroad


extension Butter {
    static var analog: AnalogBroad = .init()
    static var common: Butter = .init(broads: Butter.analog)
}
