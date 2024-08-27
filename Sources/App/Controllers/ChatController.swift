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

        let chatroom = routes.grouped("chatroom")
        let chatroomMessage = chatroom.grouped(":chatroomId", "message")

        chatroomMessage.post("", use: sendMessage)
        chatroomMessage.get(":id", use: getMessageById)
        chatroomMessage.get("", use: getMessages)
        chatroomMessage.post(":id", "click", use: clickOnMessage)

        routes.post("reset", use: reset)
        routes.post("reset", ":chatroomId", use: reset)
    }

    /**
     * Resets the state.
     */
    @Sendable
    func reset(req: Request) async throws -> HTTPStatus {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) }
        if let chatroomId {
            await ChatManager.shared.reset(chatroomId: chatroomId)

        } else {
            await ChatManager.shared.reset()
        }
        await UpdateManager.shared.reset()
        return .ok
    }

    @Sendable
    func sendMessage(req: Request) async throws -> SendMessageResponse {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID

        let body = try req.content.decode(SendMessageRequest.self)
        let message = await ChatManager.shared.addMessage(chatroomId: chatroomId, body.toMessage())
        await UpdateManager.shared.addUpdate(chatroomId: chatroomId, message)

        return SendMessageResponse(
            message_id: message.messageId!,
            chat_id: await ChatManager.shared.chatId
        )
    }

    @Sendable
    func getMessages(req: Request) async throws -> ListMessageResponse {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID

        let messages = await ChatManager.shared.messages[chatroomId, default: []]
        return ListMessageResponse(messages: messages, count: messages.count)
    }

    @Sendable
    func getMessageById(req: Request) async throws -> GetMessageByIdResponse {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id parameter")
        }
        guard let intId = Int(id) else {
            throw Abort(.badRequest, reason: "Invalid id parameter, must be an integer")
        }
        guard let message = await ChatManager.shared.getMessageById(chatroomId: chatroomId, intId) else {
            throw Abort(.notFound, reason: "Message with id \(intId) not found")
        }
        return GetMessageByIdResponse(message: message)
    }

    /**
     * Simulates a user touching a button
     */
    @Sendable
    func clickOnMessage(req: Request) async throws -> UpdateMessageByIdResponse {
        let chatroomId = req.parameters.get("chatroomId").flatMap { Int($0) } ?? DEFAULT_CHATROOM_ID
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id parameter")
        }
        guard let intId = Int(id) else {
            throw Abort(.badRequest, reason: "Invalid id parameter, must be an integer")
        }
        let body = try req.content.decode(ClickOnMessageRequest.self)
        let message = await ChatManager.shared.getMessageById(chatroomId: chatroomId, intId)

        // find the button with the text
        let button = message?.replyMarkup?.inlineKeyboard?.compactMap {
            button in
            button.first(where: { $0.text == body.text })
        }.first

        guard let callback = button else {
            throw Abort(.notFound, reason: "Button with text \(body.text) not found")
        }

        let newMessage = Message(messageId: intId, callbackQuery: callback.callbackData)
        await UpdateManager.shared.addUpdate(chatroomId: chatroomId, newMessage)
        return UpdateMessageByIdResponse(message: newMessage)
    }
}
