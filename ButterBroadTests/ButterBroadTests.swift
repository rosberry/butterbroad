//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import XCTest
@testable import ButterBroad

final class ButterBroadTests: XCTestCase {

    final class MockedAnalytics: Analytics {
        var events = [Event]()

        func log(_ event: Event) {
            events.append(event)
        }
    }

    func testLogEvent() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)
        let date = Date()

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.log(Event(name: "test_event"))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.params.isEmpty, "Params not expected")
        XCTAssert(date.timeIntervalSince(event.date) < 0.1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithName() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)
        let date = Date()

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(event.name == "test_event", "Event should have name 'test_event'")
        XCTAssert(event.params.isEmpty, "Params not expected")
        XCTAssert(date.timeIntervalSince(event.date) < 0.1, "Event date should be nearly match with sending time")
    }

    func testLogEventWithParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.log(Event(name: "test_event", params: ["param_1": .string("test")]))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(!event.params.isEmpty, "1 Params is expected")
        assertParam(event.params["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)

        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event", params: ["param_1": .string("test")])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(event.params.count == 1, "1 Params is expected")
        assertParam(event.params["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }
    
    func testLogEventWithNameAndIntParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)
        
        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event", params: ["param_1": .int(10)])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(event.params.count == 1, "1 Params is expected")
        assertParam(event.params["param_1"], value: 10, message: "Expected 'param_1' = 10")
    }
    
    func testLogEventWithNameAndFloatParam() {
        let mockedAnalytics = MockedAnalytics()
        let butterbroad = Butter(broads: mockedAnalytics)
        
        let expectation = self.expectation(description: "Event Sending")
        butterbroad.logEvent(with: "test_event", params: ["param_1": .float(0.12345)])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let event = first(in: mockedAnalytics)
        XCTAssert(event.params.count == 1, "1 Params is expected")
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
    
    private func assertParam(_ param: Param?, value: Any, message: String) {
        guard let param = param else {
            XCTAssert(false, message)
            return
        }
        switch param {
        case .string(let string):
            guard let value = value as? String, value == string else {
                return XCTAssert(false, message)
            }
        case .int(let int):
            guard let value = value as? Int, value == int else {
                return XCTAssert(false, message)
            }
        case .float(let float):
            var controlValue: Float?
            if let double = value as? Double {
                controlValue = Float(double)
            }
            else {
                controlValue = value as? Float
            }
            guard let value = controlValue, abs(value - float) < 1e-6 else {
                return XCTAssert(false, message)
            }
        }
    }
}
