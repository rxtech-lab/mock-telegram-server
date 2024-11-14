import AnyCodable
import Vapor

public struct Update: Content {
    let updateId: Int
    let message: TelegramMessage?
    let callbackQuery: CallbackQuery?

    enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case message
        case callbackQuery = "callback_query"
    }
}

public struct GetTelegramUpdatesResponse: Content {
    let ok: Bool
    let result: [Update]
}

public struct SetTelegramMyCommandsResponse: Content {
    let ok: Bool
}

public struct ReplyMarkup: Sendable, Content {
    public let inlineKeyboard: [[InlineKeyboardButton]]?

    enum CodingKeys: String, CodingKey {
        case inlineKeyboard = "inline_keyboard"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inlineKeyboard = try container.decodeIfPresent(
            [[InlineKeyboardButton]].self, forKey: .inlineKeyboard)
    }

    public init(inlineKeyboard: [[InlineKeyboardButton]]) {
        self.inlineKeyboard = inlineKeyboard
    }
}

public struct InlineKeyboardButton: Sendable, Content {
    public let text: String
    public let callbackData: String?
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case text
        case callbackData = "callback_data"
        case url
    }

    var parsedCallbackData: [String: AnyCodable] {
        guard let callbackData = callbackData else {
            return [:]
        }

        let data = Data(callbackData.utf8)
        guard let json = try? JSONDecoder().decode([String: AnyCodable].self, from: data) else {
            return [:]
        }
        return json
    }

    public init(text: String, callbackData: String, url: String? = nil) {
        self.text = text
        self.callbackData = callbackData
        self.url = url
    }
}

public struct SendTelegramMessageRequest: Content {
    let parseMode: ParseMode
    let chatId: Int
    let messageId: Int?
    let text: String
    let replyMarkup: String?

    enum ParseMode: String, Codable {
        case markdown = "Markdown"
        case html = "HTML"
    }

    enum CodingKeys: String, CodingKey {
        case parseMode = "parse_mode"
        case chatId = "chat_id"
        case text
        case replyMarkup = "reply_markup"
        case messageId = "message_id"
    }

    var parsedReplyMarkup: ReplyMarkup? {
        guard let replyMarkup = replyMarkup else {
            return nil
        }

        let data = Data(replyMarkup.utf8)
        let json = try? JSONDecoder().decode(ReplyMarkup.self, from: data)
        return json
    }
}

public struct SendTelegramMessageResponse: Content {
    let ok: Bool
}

extension SendTelegramMessageRequest {
    public func toMessage(userId: Int) -> Message {
        return Message(
            messageId: messageId, text: text, replyMarkup: parsedReplyMarkup, callbackQuery: nil,
            userId: userId)
    }
}
