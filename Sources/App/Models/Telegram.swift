import AnyCodable
import Vapor

struct Update: Content {
    let updateId: Int
    let message: TelegramMessage?
    let callbackQuery: CallbackQuery?

    enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case message
        case callbackQuery = "callback_query"
    }
}

struct GetTelegramUpdatesResponse: Content {
    let ok: Bool
    let result: [Update]
}

struct SetTelegramMyCommandsResponse: Content {
    let ok: Bool
}

struct ReplyMarkup: Content {
    let inlineKeyboard: [[InlineKeyboardButton]]?

    enum CodingKeys: String, CodingKey {
        case inlineKeyboard = "inline_keyboard"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inlineKeyboard = try container.decodeIfPresent([[InlineKeyboardButton]].self, forKey: .inlineKeyboard)
    }
}

struct InlineKeyboardButton: Content {
    let text: String
    let callbackData: String?
    let url: String?

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
        let json = try! JSONDecoder().decode([String: AnyCodable].self, from: data)
        return json
    }
}

struct SendTelegramMessageRequest: Content {
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
        let json = try! JSONDecoder().decode(ReplyMarkup.self, from: data)
        return json
    }
}

struct SendTelegramMessageResponse: Content {
    let ok: Bool
}

extension SendTelegramMessageRequest {
    func toMessage() -> Message {
        return Message(messageId: messageId, text: text, replyMarkup: parsedReplyMarkup, callbackQuery: nil)
    }
}
