@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
        app = nil
    }

    func testAddMessage() async throws {
        try await app.test(.POST, "message", beforeRequest: {
            req in
            try req.content.encode(["type": "text", "content": "Hello, world!"])
        }, afterResponse: { req async throws in
            let response = try req.content.decode(SendMessageResponse.self)
            XCTAssertEqual(response.chat_id, 0)
            XCTAssertEqual(response.message_id, 0)
            XCTAssert(req.status == .ok)
        })

        try await app.test(.POST, "message", beforeRequest: {
            req in
            try req.content.encode(["type": "text", "content": "Hello, world!"])
        }, afterResponse: { req async throws in
            let response = try req.content.decode(SendMessageResponse.self)
            XCTAssertEqual(response.chat_id, 0)
            XCTAssertEqual(response.message_id, 1)
            XCTAssert(req.status == .ok)
        })
    }
}
