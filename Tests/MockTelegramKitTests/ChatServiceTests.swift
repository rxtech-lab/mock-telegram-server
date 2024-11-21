import XCTest

@testable import MockTelegramKit

final class MockTelegramKitTests: XCTestCase {
    func testSendAndGetMessages() async throws {
        #if os(macOS)
            var messages = await ChatManager.shared.getMessagesByChatroom(chatroomId: 1)
            XCTAssertEqual(messages.count, 0)
            _ = await ChatManager.shared.sendMessage(
                chatroomId: 1, messageRequest: .init(type: .text, content: "Hello world"))
            messages = await ChatManager.shared.getMessagesByChatroom(chatroomId: 1)
            XCTAssertEqual(messages.count, 1)

            // reply to a message
            let request: SendTelegramMessageRequest = .init(
                parseMode: .html, chatId: 1, messageId: nil, text: "OK", replyMarkup: nil)
            _ = await ChatManager.shared.addMessage(
                chatroomId: 1, request.toMessage(userId: .BotUserId))
            messages = await ChatManager.shared.getMessagesByChatroom(chatroomId: 1)
            XCTAssertEqual(messages.count, 2)
            // every id should be unique
            XCTAssertNotEqual(messages[0].messageId, messages[1].messageId)
        #endif
    }

    func testEncodeAndDecodeWebhookError() {
        let error = WebhookError.invalidURL
        let data = try! JSONEncoder().encode(error)
        let decodedError = try! JSONDecoder().decode(WebhookError.self, from: data)
        XCTAssertEqual(error.errorDescription, decodedError.errorDescription)

        let error2 = WebhookError.webhookCallFailed("Some reason")
        let data2 = try! JSONEncoder().encode(error2)
        let decodedError2 = try! JSONDecoder().decode(WebhookError.self, from: data2)
        XCTAssertEqual(error2.errorDescription, decodedError2.errorDescription)

        let error3 = WebhookError.webhookNotFound(.init())
        let data3 = try! JSONEncoder().encode(error3)
        let decodedError3 = try! JSONDecoder().decode(WebhookError.self, from: data3)
        XCTAssertEqual(error3.errorDescription, decodedError3.errorDescription)
    }
}
