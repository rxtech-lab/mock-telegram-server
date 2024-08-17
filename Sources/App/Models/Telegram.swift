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

struct SendTelegramMessageRequest: Content {
    let parseMode: ParseMode
    let chatId: Int
    let text: String

    enum ParseMode: String, Content {
        case markdown = "Markdown"
        case html = "HTML"
    }

    enum CodingKeys: String, CodingKey {
        case parseMode = "parse_mode"
        case chatId = "chat_id"
        case text
    }
}

struct SendTelegramMessageResponse: Content {
    let ok: Bool
}
