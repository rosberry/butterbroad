//
//  FaceBookBroadTests.swift
//  FaceBookBroadTests
//
//  Created by Nick Tyunin on 09/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import XCTest
import ButterBroad
import FBSDKCoreKit

extension AppEvents {
    @objc public static func logMockedEvent(eventName: AppEvents.Name, parameters: [String: Any]) {
        MockedAnalytics.shared.log(.init(name: eventName.rawValue, parameters: parameters))
    }

    static func swizzle() {
        let aClass: AnyClass! = AppEvents.self
        let originalMethod = class_getClassMethod(aClass, #selector(logEvent(_:parameters:)))
        let swizzledMethod = class_getClassMethod(aClass, #selector(logMockedEvent(eventName:parameters:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

class FacebookBroadTests: XCTestCase {
    var butterbroad: Butter!
    var expectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        AppEvents.swizzle()
        MockedAnalytics.shared.events = []
        butterbroad = Butter(broads: FacebookBroad())
        expectation = self.expectation(for: NSPredicate(block: { analytics, _ in
            guard let analytics = analytics as? MockedAnalytics, analytics.events.count > 0 else {
                return false
            }
            return true
        }), evaluatedWith: MockedAnalytics.shared, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        AppEvents.swizzle()
        butterbroad = nil
        expectation = nil
    }

    func testLogEvent() {
        butterbroad.log(Event(name: "test_event"))
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.parameters?.isEmpty == true, "Params not expected")
    }

    func testLogEventWithName() {
        butterbroad.logEvent(with: "test_event")
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.parameters?.isEmpty == true, "Params not expected")
    }

    func testLogEventWithParam() {
        butterbroad.log(Event(name: "test_event", params: ["param_1": "test"]))
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.parameters?.count == 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": "test"])
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.parameters?.count == 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndIntParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 10])
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.parameters?.count == 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: 10, message: "Expected 'param_1' = 10")
    }

    func testLogEventWithNameAndFloatParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 0.12345])
        wait(for: [expectation], timeout: 10)
        let event = first(in: MockedAnalytics.shared)
        XCTAssert(event.parameters?.count == 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: 0.12345, message: "Expected 'param_1' = 0.12345")
    }

    // MARK: - Private

    private func first(in analytics: MockedAnalytics) -> MockedEvent {
        guard let event = analytics.events.first else {
            XCTAssert(false, "Event should be logged")
            assert(false)
        }
        return event
    }

    private func assertParam(_ param: Any?, value: AnyCodable, message: String) {
        guard let param = param as? AnyCodable, param == value else {
            XCTAssert(false, message)
            return
        }
    }
}
