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
        message.post(":id", "click", use: clickOnMessage)

        routes.post("reset", use: reset)
    }

    /**
     * Resets the state.
     */
    func reset(req _: Request) async throws -> HTTPStatus {
        await ChatManager.shared.reset()
        await UpdateManager.shared.reset()
        return .ok
    }

    func sendMessage(req: Request) async throws -> SendMessageResponse {
        let body = try req.content.decode(SendMessageRequest.self)
        let message = await ChatManager.shared.addMessage(body.toMessage())
        await UpdateManager.shared.addUpdate(message)

        return SendMessageResponse(
            message_id: message.messageId!,
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

    /**
     * Simulates a user touching a button
     */
    func clickOnMessage(req: Request) async throws -> UpdateMessageByIdResponse {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id parameter")
        }
        guard let intId = Int(id) else {
            throw Abort(.badRequest, reason: "Invalid id parameter, must be an integer")
        }
        let body = try req.content.decode(ClickOnMessageRequest.self)
        let message = await ChatManager.shared.getMessageById(intId)

        // find the button with the text
        let button = message?.replyMarkup?.inlineKeyboard.compactMap {
            button in
            button.first(where: { $0.text == body.text })
        }.first

        guard let callback = button else {
            throw Abort(.notFound, reason: "Button with text \(body.text) not found")
        }

        let newMessage = Message(messageId: intId, callbackQuery: callback.callbackData)
        await UpdateManager.shared.addUpdate(newMessage)
        return UpdateMessageByIdResponse(message: newMessage)
    }
}
