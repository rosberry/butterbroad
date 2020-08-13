//
//  Event.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

// Struct for an event instance that provides basic information that can be sent
// to the analytics service

public struct Event: Codable {
    public let name: String
    public let params: [String: AnyCodable]
    public let date: Date

    public init(name: String, params: [String: AnyCodable] = [:]) {
        self.name = name
        self.params = params
        self.date = Date()
    }
}
