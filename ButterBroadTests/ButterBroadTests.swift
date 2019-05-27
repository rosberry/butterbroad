//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import XCTest
@testable import ButterBroad

class ButterBroadTests: XCTestCase {

    class MockedAnalytics: Analytics {
        var events = [Event]()

        func logEvent(_ event: Event) {
            events.append(event)
        }
    }

    func testLogEvent() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = ButterBroad(with: mockedAnalytics)
        let date = Date()

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(Event(name: "test_event"))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        guard let event = mockedAnalytics.events.first else {
            XCTAssert(false, "Event should be logged")
            return
        }
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.params.count == 0, "Params not expected")
        XCTAssert(date.timeIntervalSince(event.date) < 0.1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithName() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = ButterBroad(with: mockedAnalytics)
        let date = Date()

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        guard let event = mockedAnalytics.events.first else {
            XCTAssert(false, "Event should be logged")
            return
        }
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.params.count == 0, "Params not expected")
        XCTAssert(date.timeIntervalSince(event.date) < 0.1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = ButterBroad(with: mockedAnalytics)

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(Event(name: "test_event", params: ["param_1": "test"]))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        guard let event = mockedAnalytics.events.first else {
            XCTAssert(false, "Event should be logged")
            return
        }
        XCTAssert(event.params.count == 1, "1 Params is expected")
        guard let param = event.params["param_1"], param == "test" else {
            XCTAssert(false, "Expected 'param_1' = 'test'")
            return
        }
    }

    func testLogEventWithNameAndParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = ButterBroad(with: mockedAnalytics)

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event", params: ["param_1": "test"])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        guard let event = mockedAnalytics.events.first else {
            XCTAssert(false, "Event should be logged")
            return
        }
        XCTAssert(event.params.count == 1, "1 Params is expected")
        guard let param = event.params["param_1"], param == "test" else {
            XCTAssert(false, "Expected 'param_1' = 'test'")
            return
        }
    }
}
