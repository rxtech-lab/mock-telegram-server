import Vapor

/**
 ChatController simulates the user's chat with the bot.
 Unlike the TelegramController, the ChatController does not interact with the Telegram API.
 */
struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let message = routes.grouped("message")
        message.post("", use: sendMessage)
        message.get(":id", use: getMessageById)
        message.get("", use: getMessages)
    }

    func sendMessage(req: Request) async throws -> SendMessageResponse {
        let body = try req.content.decode(SendMessageRequest.self)
        let message = await ChatManager.shared.addMessage(body.toMessage())
        await UpdateManager.shared.addUpdate(message)

        return SendMessageResponse(
            message_id: message.messageId,
            chat_id: await ChatManager.shared.chatId
        )
    }

    func getMessages(req _: Request) async throws -> ListMessageResponse {
        let messages = await ChatManager.shared.messages
        return ListMessageResponse(messages: messages, count: messages.count)
    }

    func getMessageById(req: Request) async throws -> GetMessageByIdResponse {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id parameter")
        }
        guard let intId = Int(id) else {
            throw Abort(.badRequest, reason: "Invalid id parameter, must be an integer")
        }
        guard let message = await ChatManager.shared.getMessageById(intId) else {
            throw Abort(.notFound, reason: "Message with id \(intId) not found")
        }
        return GetMessageByIdResponse(message: message)
    }
}
