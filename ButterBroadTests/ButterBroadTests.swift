//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import XCTest
@testable import ButterBroad

final class ButterBroadTests: XCTestCase {

    final class MockedAnalytics: Analytics {
        var activationHandler: (() -> Void)?

        var events = [Event]()

        func log(_ event: Event) {
            events.append(event)
        }
    }

    var analytics: MockedAnalytics!
    var butterbroad: Butter!
    var date: Date!
    var expectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        analytics = MockedAnalytics()
        butterbroad = Butter(broads: analytics)
        date = Date()
        expectation = self.expectation(for: NSPredicate(block: { analytics, _ in
            guard let analytics = analytics as? MockedAnalytics, analytics.events.count > 0 else {
                return false
            }
            return true
        }), evaluatedWith: analytics, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        analytics = nil
        butterbroad = nil
        date = nil
        expectation = nil
    }

    func testLogEvent() {
        butterbroad.log(Event(name: "test_event"))
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertEqual(event.name, "test_event", "Event should have name 'test_event'")
        XCTAssertTrue(event.params.isEmpty, "Params not expected")
        XCTAssertLessThan(date.timeIntervalSince(event.date), 1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithName() {
        butterbroad.logEvent(with: "test_event")
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertEqual(event.name, "test_event", "Event should have name 'test_event'")
        XCTAssertTrue(event.params.isEmpty, "Params not expected")
        XCTAssertLessThan(date.timeIntervalSince(event.date), 1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithParam() {
        butterbroad.log(Event(name: "test_event", params: ["param_1": "test"]))
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertFalse(event.params.isEmpty, "1 Params is expected")
        assertParam(event.params["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": "test"])
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertEqual(event.params.count, 1, "1 Params is expected")
        assertParam(event.params["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndIntParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 10])
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertEqual(event.params.count, 1, "1 Params is expected")
        assertParam(event.params["param_1"], value: 10, message: "Expected 'param_1' = 10")
    }

    func testLogEventWithNameAndFloatParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 0.12345])
        wait(for: [expectation], timeout: 10)
        let event = first(in: analytics)
        XCTAssertEqual(event.params.count, 1, "1 Params is expected")
        assertParam(event.params["param_1"], value: 0.12345, message: "Expected 'param_1' = 0.12345")
    }

    // MARK: - Private

    private func first(in analytics: MockedAnalytics) -> Event {
        guard let event = analytics.events.first else {
            XCTAssert(false, "Event should be logged")
            assert(false)
        }
        return event
    }

    private func assertParam(_ param: AnyCodable?, value: AnyCodable, message: String) {
        guard let param = param, param == value else {
            XCTAssert(false, message)
            return
        }
    }
}
