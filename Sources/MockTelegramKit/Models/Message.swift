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

    struct ParserResult {
        let command: String
        let offset: Int
        let length: Int

        var entity: MessageEntity {
            MessageEntity(type: .botCommand, offset: offset, length: length, url: nil, user: nil, language: nil, customEmojiId: nil)
        }
    }

    func parseCommand(_ input: String, startIndex: String.Index) -> ParserResult? {
        guard let slashIndex = input[startIndex...].firstIndex(of: "/") else {
            return nil
        }

        let commandStart = input.index(after: slashIndex)
        let remainingString = input[commandStart...]

        let commandEnd = remainingString.firstIndex(where: { $0.isWhitespace }) ?? remainingString.endIndex
        let command = String(remainingString[..<commandEnd])

        if command.isEmpty {
            return nil
        }

        let offset = input.distance(from: input.startIndex, to: slashIndex)
        let length = input.distance(from: slashIndex, to: commandEnd)

        return ParserResult(command: command, offset: offset, length: length)
    }

    func parseAllCommands(_ input: String) -> [ParserResult] {
        var results: [ParserResult] = []
        var currentIndex = input.startIndex

        while currentIndex < input.endIndex {
            if let result = parseCommand(input, startIndex: currentIndex) {
                results.append(result)
                currentIndex = input.index(input.startIndex, offsetBy: result.offset + result.length)
            } else {
                currentIndex = input.index(after: currentIndex)
            }
        }

        return results
    }

    func toMessage() -> Message {
        let command: [SendMessageRequest.ParserResult] = parseAllCommands(content)
        return Message(messageId: nil, text: content, entities: command.map { $0.entity })
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
