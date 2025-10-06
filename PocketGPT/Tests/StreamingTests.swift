import XCTest
@testable import PocketGPT

final class StreamingTests: XCTestCase {
    func testSSEEventParsing() throws {
        let lines = [
            "event: token",
            "data: {\"delta\":\"Hello\"}",
            "",
            "event: done",
            "data: {\"usage\":{}}"
        ]
        let events = SSEClient.parse(lines: lines)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.event, "token")
        XCTAssertEqual(String(data: events.first!.data, encoding: .utf8), "{\"delta\":\"Hello\"}")
    }
}
