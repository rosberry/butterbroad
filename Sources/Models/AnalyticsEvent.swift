//
//  Event.swift
//  ButterBroad
//
//  Created by Nick Tyunin on 17/05/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

// Struct for an event instanse that provides basic information that can be sent
// to the analytics service

public struct AnalyticsEvent: Codable {
    public let name: String
    public let params: [String: String]
    public let date: Date

    init(name: String, params: [String: String] = [:]) {
        self.name = name
        self.params = params
        self.date = Date()
    }
}
