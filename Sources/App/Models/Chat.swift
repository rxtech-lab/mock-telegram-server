import Vapor

struct Message: Content {
    var messageId: Int?
    var text: String?
    var replyMarkup: ReplyMarkup?
    var callbackQuery: String?

    var updateCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case text
        case updateCount = "update_count"
        case replyMarkup = "reply_markup"
        case callbackQuery = "callback_query"
    }
}

struct Chat: Content {
    let id: Int
    let message: Message
}

// MARK: - Chat to Telegram Message

extension Message {
    func toCallbackQuery() -> CallbackQuery {
        return CallbackQuery(
            id: UUID().uuidString,
            from: User(id: 0, isBot: false, firstName: "John", lastName: "Doe", username: "johndoe", languageCode: "en"),
            message: toTelegramMessage(fromCallbackQuery: true),
            inlineMessageId: nil,
            chatInstance: UUID().uuidString,
            data: callbackQuery,
            gameShortName: nil
        )
    }

    func toTelegramMessage(fromCallbackQuery: Bool = false) -> TelegramMessage? {
        if !fromCallbackQuery, callbackQuery != nil {
            return nil
        }

        return TelegramMessage(
            messageId: messageId!,
            messageThreadId: nil,
            from: nil,
            date: Int(Date().timeIntervalSince1970),
            chat: .init(id: 0, type: .privateChat),
            senderChat: nil,
            forwardFrom: nil,
            forwardFromChat: nil,
            forwardFromMessageId: nil,
            forwardSignature: nil,
            forwardSenderName: nil,
            forwardDate: nil,
            isTopicMessage: nil,
            editDate: nil,
            mediaGroupId: nil,
            authorSignature: nil,
            text: text,
            entities: nil,
            captionEntities: nil,
            audio: nil,
            document: nil,
            animation: nil,
            game: nil,
            photo: nil,
            sticker: nil,
            video: nil,
            voice: nil,
            videoNote: nil,
            caption: nil,
            newChatMembers: nil,
            leftChatMember: nil,
            newChatTitle: nil,
            newChatPhoto: nil,
            deleteChatPhoto: nil,
            groupChatCreated: nil,
            supergroupChatCreated: nil,
            channelChatCreated: nil,
            migrateToChatId: nil,
            migrateFromChatId: nil,
            hasMediaSpoiler: nil
        )
    }
}
