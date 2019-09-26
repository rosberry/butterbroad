//
//  Event.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

// Struct for an event instance that provides basic information that can be sent
// to the analytics service

public enum Param {
    case int(_ value: Int)
    case float(_ value: Float)
    case string(_ value: String)
}

public struct Event: Codable {
    public let name: String
    public let params: [String: Param]
    public let date: Date

    public init(name: String, params: [String: Param] = [:]) {
        self.name = name
        self.params = params
        self.date = Date()
    }
}

extension Param: Codable {
    
    public enum Error: Swift.Error {
        case unparsable
    }
    
    private enum Key: CodingKey {
        case key
        case value
    }
    
    private static let key_string = "string"
    private static let key_int = "int"
    private static let key_float = "float"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case Param.key_string:
            let value = try container.decode(String.self, forKey: .value)
            self = .string(value)
        case Param.key_int:
            let value = try container.decode(Int.self, forKey: .value)
            self = .int(value)
        case Param.key_float:
            let value = try container.decode(Float.self, forKey: .value)
            self = .float(value)
        default:
            throw Error.unparsable
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .string(let value):
            try container.encode(Param.key_string, forKey: .key)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode(Param.key_int, forKey: .key)
            try container.encode(value, forKey: .value)
        case .float(let value):
            try container.encode(Param.key_float, forKey: .key)
            try container.encode(value, forKey: .value)
        }
    }
}
