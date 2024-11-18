import AnyCodable
import XCTVapor

@testable import App
@testable import MockTelegramKit

final class AppTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
        app = nil
        await UpdateManager.shared.reset()
        await ChatManager.shared.reset()
    }

    func testAddAndGetMessage() async throws {
        try await app.test(
            .POST, "message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 0)
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .POST, "message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 1)
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .GET, "message",
            afterResponse: {
                res async throws in
                let resp = try res.content.decode(ListMessageResponse.self)
                XCTAssertEqual(resp.messages.count, 2)
                XCTAssertEqual(resp.messages[0].messageId, 0)
                XCTAssertEqual(resp.messages[1].messageId, 1)
            })

        // get updates
        try await app.test(
            .GET, "message/0",
            afterResponse: {
                res async throws in
                let resp = try res.content.decode(GetMessageByIdResponse.self)
                XCTAssertEqual(resp.message.messageId, 0)
                XCTAssertEqual(resp.message.text, "Hello, world!")
            })

        // get updates
        try await app.test(
            .POST, "webhook/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 2)
                XCTAssertEqual(response.result[0].message?.text, "Hello, world!")
                XCTAssertEqual(response.result[1].message?.text, "Hello, world!")
            })

        // get updates again
        try await app.test(
            .POST, "webhook/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 0)

            })
    }

    func testAddAndGetMessagePerChatroom() async throws {
        let chatroomId = 2

        try await app.test(
            .POST, "chatroom/\(chatroomId)/message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 0)
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .POST, "chatroom/\(chatroomId)/message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 1)
                XCTAssert(req.status == .ok)
            })

        // add message to another chatroom
        try await app.test(
            .POST, "message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 2)
                XCTAssert(req.status == .ok)
            })

        // list message by chatroom
        try await app.test(
            .GET, "chatroom/\(chatroomId)/message",
            afterResponse: {
                res async throws in
                let resp = try res.content.decode(ListMessageResponse.self)
                XCTAssertEqual(resp.messages.count, 2)
                XCTAssertEqual(resp.messages[0].messageId, 0)
                XCTAssertEqual(resp.messages[1].messageId, 1)
            })

        try await app.test(
            .GET, "chatroom/\(chatroomId)/message/0",
            afterResponse: {
                res async throws in
                let resp = try res.content.decode(GetMessageByIdResponse.self)
                XCTAssertEqual(resp.message.messageId, 0)
                XCTAssertEqual(resp.message.text, "Hello, world!")
            })

        // get updates
        try await app.test(
            .POST, "webhook/chatroom/\(chatroomId)/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 2)
                XCTAssertEqual(response.result[0].message?.text, "Hello, world!")
                XCTAssertEqual(response.result[1].message?.text, "Hello, world!")
            })

        // get updates again
        try await app.test(
            .POST, "webhook/chatroom/\(chatroomId)/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 0)

            })
    }

    func testTelegramSendMessage() async throws {
        let chatroomId = 3

        try await app.test(
            .POST, "chatroom/\(chatroomId)/message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello, world!"])
            },
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 0)
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .POST, "webhook/chatroom/\(chatroomId)/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 1)
                XCTAssertEqual(response.result[0].message?.text, "Hello, world!")
            })

        // respond to the message
        try await app.test(
            .POST, "webhook/chatroom/\(chatroomId)/abc/sendMessage",
            beforeRequest: {
                req in
                try req.content.encode(
                    SendTelegramMessageRequest(
                        parseMode: .html, chatId: chatroomId, messageId: nil, text: "Some response",
                        replyMarkup: nil))
            },
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .GET, "chatroom/\(chatroomId)/message",
            afterResponse: {
                res async throws in
                let resp = try res.content.decode(ListMessageResponse.self)
                XCTAssertEqual(resp.messages.count, 2)
                XCTAssertEqual(resp.messages[0].messageId, 0)
                XCTAssertEqual(resp.messages[1].messageId, 1)
                XCTAssertEqual(resp.messages[0].toTelegramMessage()?.from?.isBot, false)
                XCTAssertEqual(resp.messages[1].toTelegramMessage()?.from?.isBot, true)
            })
    }

    func testSendMessageWithCommands() async throws {
        let chatroomId = 4

        try await app.test(
            .POST, "chatroom/\(chatroomId)/message",
            beforeRequest: {
                req in
                try req.content.encode(["type": "text", "content": "Hello /start"])
            },
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(SendMessageResponse.self)
                XCTAssertEqual(response.chat_id, 0)
                XCTAssertEqual(response.message_id, 0)
                XCTAssert(req.status == .ok)
            })

        try await app.test(
            .POST, "webhook/chatroom/\(chatroomId)/abc/getUpdates",
            afterResponse: { req async throws in
                XCTAssert(req.status == .ok)
                let response = try req.content.decode(GetTelegramUpdatesResponse.self)
                XCTAssertEqual(response.result.count, 1)
                XCTAssertEqual(response.result[0].message?.text, "Hello /start")
                XCTAssertEqual(response.result[0].message?.entities?.count, 1)

                let entity = response.result[0].message?.entities?.first
                XCTAssertEqual(entity?.type, MessageEntityType.botCommand)
                XCTAssertEqual(entity?.offset, 6)
                XCTAssertEqual(entity?.length, 6)
            })
    }
}
