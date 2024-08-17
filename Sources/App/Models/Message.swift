import Vapor

enum MessageType: String, Content {
    /**
     * Text message. Simulates a user pressing the Enter key and sending a message.
     */
    case text
    /**
     * Callback message. Simulates a user pressing a button.
     */
    case callback
}

struct SendMessageRequest: Content {
    let type: MessageType
    /**
     * The message text. Could be a command, a question, or any other text.
     */
    let content: String

    func toMessage() -> Message {
        return Message(messageId: nil, text: content)
    }
}

struct SendMessageResponse: Content {
    var message_id: Int
    let chat_id: Int
}

struct GetMessageByIdResponse: Content {
    let message: Message
}

struct ListMessageResponse: Content {
    let messages: [Message]
    let count: Int
}

struct UpdateMessageByIdResponse: Content {
    let message: Message
}

struct ClickOnMessageRequest: Content {
    let text: String
}
