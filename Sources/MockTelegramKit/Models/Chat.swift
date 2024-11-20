import Vapor

public struct Message: Content, Sendable {
    public var messageId: Int?
    public var text: String?
    public var replyMarkup: ReplyMarkup?
    public var callbackQuery: String?
    public var entities: [MessageEntity]?
    public var userId: Int
    /**
     The error that occurred when sending the message
    */
    public var error: LocalizedError?

    public var updateCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case text
        case updateCount = "update_count"
        case replyMarkup = "reply_markup"
        case callbackQuery = "callback_query"
        case userId = "user_id"
        case entities
    }

    public init(
        messageId: Int? = nil, text: String? = nil, replyMarkup: ReplyMarkup? = nil,
        callbackQuery: String? = nil, entities: [MessageEntity]? = nil, userId: Int
    ) {
        self.messageId = messageId
        self.text = text
        self.replyMarkup = replyMarkup
        self.callbackQuery = callbackQuery
        self.entities = entities
        self.userId = userId
    }

    public init(messageId: Int, text: String, userId: Int) {
        self.text = text
        self.userId = userId
        self.messageId = messageId
    }

    public init(messageId: Int, text: String, userId: Int, replyMarkup: ReplyMarkup) {
        self.text = text
        self.userId = userId
        self.messageId = messageId
        self.replyMarkup = replyMarkup
    }
}

public struct Chat: Content {
    let id: Int
    let message: Message
}

// MARK: - Chat to Telegram Message

extension Message {
    public func toCallbackQuery() -> CallbackQuery {
        return CallbackQuery(
            id: UUID().uuidString,
            from: User(
                id: 0, isBot: false, firstName: "John", lastName: "Doe", username: "johndoe",
                languageCode: "en"),
            message: toTelegramMessage(fromCallbackQuery: true),
            inlineMessageId: nil,
            chatInstance: UUID().uuidString,
            data: callbackQuery,
            gameShortName: nil
        )
    }

    public func toTelegramMessage(fromCallbackQuery: Bool = false) -> TelegramMessage? {
        if !fromCallbackQuery, callbackQuery != nil {
            return nil
        }

        return TelegramMessage(
            messageId: messageId!,
            messageThreadId: nil,
            from: User(
                id: userId, isBot: userId == Int.BotUserId ? true : false, firstName: "John",
                lastName: "Doe", username: "johndoe",
                languageCode: "en"),
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
            entities: entities,
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

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.messageId == rhs.messageId && lhs.text == rhs.text && lhs.replyMarkup == rhs.replyMarkup
            && lhs.callbackQuery == rhs.callbackQuery && lhs.entities == rhs.entities
            && lhs.userId == rhs.userId && lhs.updateCount == rhs.updateCount
    }
}
