import AnyCodable
import Foundation
import Vapor

struct TelegramController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webhook = routes.grouped("webhook")
        let chatroom = webhook.grouped("chatroom", ":chatroomId")

        webhook.post(":token", "getUpdates", use: getUpdates)
        webhook.post(":token", "setMyCommands", use: setMyCommands)
        webhook.post(":token", "sendMessage", use: sendMessage)
        webhook.post(":token", "editMessageText", use: editMessagetext)
        webhook.post(":token", "close", use: close)

        chatroom.post(":token", "getUpdates", use: getUpdates)
        chatroom.post(":token", "setMyCommands", use: setMyCommands)
        chatroom.post(":token", "sendMessage", use: sendMessage)
        chatroom.post(":token", "editMessageText", use: editMessagetext)
        chatroom.post(":token", "close", use: close)
    }

    @Sendable
    func close(req _: Request) async throws -> CloseResponse {
        return CloseResponse()
    }

    @Sendable
    func sendMessage(req: Request) async throws -> Message {
        let body = try req.content.decode(SendTelegramMessageRequest.self)
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID

        req.logger.notice("sendMessage called with message")
        _ = await ChatManager.shared.addMessage(
            chatroomId: chatroomId, body.toMessage(userId: .BotUserId))

        return body.toMessage(userId: .BotUserId)
    }

    @Sendable
    func editMessagetext(req: Request) async throws -> Message {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID
        let body = try req.content.decode(SendTelegramMessageRequest.self)

        req.logger.notice("editMessageText called with message")
        let message = body.toMessage(userId: .BotUserId)
        _ = await ChatManager.shared.updateMessageById(
            chatroomId: chatroomId, id: message.messageId!,
            message: body.toMessage(userId: .BotUserId))

        return message
    }

    @Sendable
    func getUpdates(req: Request) async throws -> GetTelegramUpdatesResponse {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID
        let updates = await UpdateManager.shared.getUpdates(chatroomId: chatroomId)
        if !updates.isEmpty {
            req.logger.notice("updates: \(updates)")
        }
        return GetTelegramUpdatesResponse(
            ok: true,
            result: updates.map {
                Update(
                    updateId: 0, message: $0.toTelegramMessage(),
                    callbackQuery: $0.toCallbackQuery())
            })
    }

    @Sendable
    func setMyCommands(req: Request) async throws -> SetTelegramMyCommandsResponse {
        let token = req.parameters.get("token")!
        req.logger.info("setMyCommands called with token: \(token)")
        // Implement setMyCommands logic here
        return SetTelegramMyCommandsResponse(ok: true)
    }
}
