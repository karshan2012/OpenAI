import Foundation

struct SSEEvent {
    let event: String
    let data: Data
}

actor SSEClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func stream(request: URLRequest, onEvent: @escaping (SSEEvent) -> Void) async throws {
        let (stream, response) = try await session.bytes(for: request)
        try await SSEClient.consume(stream: stream, response: response, onEvent: onEvent)
    }

    static func consume(stream: URLSession.AsyncBytes, response: URLResponse, onEvent: @escaping (SSEEvent) -> Void) async throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        var parser = SSEParser(onEvent: onEvent)
        for try await line in stream.lines {
            parser.process(line: line)
        }
    }

    static func parse(lines: [String]) -> [SSEEvent] {
        var events: [SSEEvent] = []
        var parser = SSEParser(onEvent: { events.append($0) })
        lines.forEach { parser.process(line: $0) }
        return events
    }

    private struct SSEParser {
        var currentEvent = "message"
        let onEvent: (SSEEvent) -> Void

        mutating func process(line: String) {
            if line.hasPrefix("event:") {
                currentEvent = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                let payload = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
                if let data = payload.data(using: .utf8) {
                    onEvent(SSEEvent(event: currentEvent, data: data))
                }
            } else if line.isEmpty {
                currentEvent = "message"
            }
        }
    }
}
