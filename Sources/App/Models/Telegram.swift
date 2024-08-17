import AnyCodable
import Vapor

struct Update: Content {
    let updateId: Int
    let message: TelegramMessage?

    enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case message
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
    let inlineKeyboard: [[InlineKeyboardButton]]

    enum CodingKeys: String, CodingKey {
        case inlineKeyboard = "inline_keyboard"
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

struct SendTelegramMessageRequest: Codable {
    let parseMode: ParseMode
    let chatId: Int
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
        return Message(messageId: 0, text: text, replyMarkup: parsedReplyMarkup)
    }
}
