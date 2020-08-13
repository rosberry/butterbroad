//
//  AnalogBroadTests.swift
//  AnalogBroadTests
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import XCTest
import ButterBroad
import Analog

final class MockedLogger: AnalogLogger {
    var events: [MockedEvent] = []

    func log(_ event: Analog.Event) {
        let components = event.description.string.split(separator: "\n")
        let title = String(components[1])
        var params = [String: Any]()
        for i in stride(from: 2, to: components.count, by: 1) {
            let pair = components[i].split(separator: ":")

            func item(at index: Int) -> String {
                return String(pair[index].trimmingCharacters(in: .whitespacesAndNewlines))
            }

            params[item(at: 0)] = AnyCodable(item(at: 1))
        }
        events.append(.init(name: title, parameters: params))
    }

    func sessionsModule() -> UIViewController {
        return .init()
    }

    func currentEventsModule() -> UIViewController {
        return .init()
    }
}

class AnalogBroadTests: XCTestCase {
    var butterbroad: Butter!
    var expectation: XCTestExpectation!
    var logger: MockedLogger!

    override func setUp() {
        super.setUp()
        logger = .init()
        butterbroad = Butter(broads: AnalogBroad(logger: logger))
        expectation = self.expectation(for: NSPredicate(block: { logger, _ in
            guard let logger = logger as? MockedLogger, logger.events.count > 0 else {
                return false
            }
            return true
        }), evaluatedWith: logger, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        butterbroad = nil
        expectation = nil
        logger = nil
    }

    func testLogEvent() {
        butterbroad.log(Event(name: "test_event"))
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.name, "test_event", "Event should have name 'test_event'")
        XCTAssert(event.parameters?.isEmpty == true, "Params not expected")
    }

    func testLogEventWithName() {
        butterbroad.logEvent(with: "test_event")
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.name, "test_event", "Event should have name 'test_event'")
        XCTAssert(event.parameters?.isEmpty == true, "Params not expected")
    }

    func testLogEventWithParam() {
        butterbroad.log(Event(name: "test_event", params: ["param_1": "test"]))
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.parameters?.count, 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithParams() {
        butterbroad.log(Event(name: "test_event", params: ["param_1": "test", "param_2": "test_2"]))
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.parameters?.count, 2, "2 Params is expected")
        assertParam(event.parameters?["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
        assertParam(event.parameters?["param_2"], value: "test_2", message: "Expected 'param_2' = 'test_2'")
    }

    func testLogEventWithNameAndParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": "test"])
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.parameters?.count, 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "test", message: "Expected 'param_1' = 'test'")
    }

    func testLogEventWithNameAndIntParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 10])
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.parameters?.count, 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "10", message: "Expected 'param_1' = 10")
    }

    func testLogEventWithNameAndFloatParam() {
        butterbroad.logEvent(with: "test_event", params: ["param_1": 0.12345])
        wait(for: [expectation], timeout: 10)
        let event = first(in: logger)
        XCTAssertEqual(event.parameters?.count, 1, "1 Params is expected")
        assertParam(event.parameters?["param_1"], value: "0.12345", message: "Expected 'param_1' = 0.12345")
    }

    // MARK: - Private

    private func first(in logger: MockedLogger) -> MockedEvent {
        guard let event = logger.events.first else {
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
