//
//  MockedAnalytics.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

struct MockedEvent {
    let name: String
    let parameters: [String: Any]?
}

final class MockedAnalytics {

    private(set) static var shared: MockedAnalytics = .init()
    var events: [MockedEvent] = []

    func log(_ event: MockedEvent) {
        events.append(event)
    }
}
