import Foundation
import Vapor

public struct User: Content, Sendable, Equatable {
    public let id: Int
    public let isBot: Bool
    public let firstName: String
    public let lastName: String?
    public let username: String?
    public let languageCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case isBot = "is_bot"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case languageCode = "language_code"
    }
}

public struct MessageEntity: Content, Sendable, Equatable {
    public let type: MessageEntityType
    public let offset: Int
    public let length: Int
    public let url: String?
    public let user: User?
    public let language: String?
    public let customEmojiId: String?

    enum CodingKeys: String, CodingKey {
        case type, offset, length, url, user, language
        case customEmojiId = "custom_emoji_id"
    }
}

public enum MessageEntityType: String, Content, Sendable {
    case mention
    case hashtag
    case cashtag
    case botCommand = "bot_command"
    case url
    case email
    case phoneNumber = "phone_number"
    case bold
    case italic
    case underline
    case strikethrough
    case code
    case pre
    case textLink = "text_link"
    case textMention = "text_mention"
    case spoiler
    case customEmoji = "custom_emoji"
}

public struct Audio: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let duration: Int
    public let performer: String?
    public let title: String?
    public let mimeType: String?
    public let fileSize: Int?
    public let thumb: PhotoSize?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case duration
        case performer
        case title
        case mimeType = "mime_type"
        case fileSize = "file_size"
        case thumb
    }
}

public struct Video: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let width: Int
    public let height: Int
    public let duration: Int
    public let thumb: PhotoSize?
    public let mimeType: String?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case duration
        case thumb
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}

public struct Voice: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let duration: Int
    public let mimeType: String?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case duration
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}

// PhotoSize struct (used in Audio and Video)
public struct PhotoSize: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let width: Int
    public let height: Int
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case fileSize = "file_size"
    }
}

public struct Document: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let thumb: PhotoSize?
    public let fileName: String?
    public let mimeType: String?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case thumb
        case fileName = "file_name"
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}

public struct Animation: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let width: Int
    public let height: Int
    public let duration: Int
    public let thumb: PhotoSize?
    public let fileName: String?
    public let mimeType: String?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case duration
        case thumb
        case fileName = "file_name"
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}

public struct Game: Content {
    public let title: String
    public let description: String
    public let photo: [PhotoSize]
    public let text: String?
    public let textEntities: [MessageEntity]?
    public let animation: Animation?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case photo
        case text
        case textEntities = "text_entities"
        case animation
    }
}

public struct Sticker: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let type: StickerType
    public let width: Int
    public let height: Int
    public let isAnimated: Bool
    public let isVideo: Bool
    public let thumb: PhotoSize?
    public let emoji: String?
    public let setName: String?
    public let premiumAnimation: File?
    public let maskPosition: MaskPosition?
    public let customEmojiId: String?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case type
        case width
        case height
        case isAnimated = "is_animated"
        case isVideo = "is_video"
        case thumb
        case emoji
        case setName = "set_name"
        case premiumAnimation = "premium_animation"
        case maskPosition = "mask_position"
        case customEmojiId = "custom_emoji_id"
        case fileSize = "file_size"
    }
}

public enum StickerType: String, Content {
    case regular
    case mask
    case customEmoji = "custom_emoji"
}

public struct VideoNote: Content {
    public let fileId: String
    public let fileUniqueId: String
    public let length: Int
    public let duration: Int
    public let thumb: PhotoSize?
    public let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case length
        case duration
        case thumb
        case fileSize = "file_size"
    }
}

// Additional structs needed for the above

public struct MaskPosition: Codable {
    public let point: String
    public let xShift: Double
    public let yShift: Double
    public let scale: Double

    enum CodingKeys: String, CodingKey {
        case point
        case xShift = "x_shift"
        case yShift = "y_shift"
        case scale
    }
}

public struct File: Codable {
    public let fileId: String
    public let fileUniqueId: String
    public let fileSize: Int?
    public let filePath: String?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case fileSize = "file_size"
        case filePath = "file_path"
    }
}

public struct TelegramChat: Codable {
    public let id: Int
    public let type: ChatType

    public enum ChatType: String, Codable {
        case privateChat = "private"
        case group
        case supergroup
        case channel
    }
}

public struct CallbackQuery: Content {
    public let id: String
    public let from: User
    public let message: TelegramMessage?
    public let inlineMessageId: String?
    public let chatInstance: String
    public let data: String?
    public let gameShortName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case from
        case message
        case inlineMessageId = "inline_message_id"
        case chatInstance = "chat_instance"
        case data
        case gameShortName = "game_short_name"
    }
}

public struct TelegramMessage: Content {
    public let messageId: Int
    public let messageThreadId: Int?
    public let from: User?
    public let date: Int
    public let chat: TelegramChat
    public let senderChat: TelegramChat?
    public let forwardFrom: User?
    public let forwardFromChat: TelegramChat?
    public let forwardFromMessageId: Int?
    public let forwardSignature: String?
    public let forwardSenderName: String?
    public let forwardDate: Int?
    public let isTopicMessage: Bool?
    public let editDate: Int?
    public let mediaGroupId: String?
    public let authorSignature: String?
    public let text: String?
    public let entities: [MessageEntity]?
    public let captionEntities: [MessageEntity]?
    public let audio: Audio?
    public let document: Document?
    public let animation: Animation?
    public let game: Game?
    public let photo: [PhotoSize]?
    public let sticker: Sticker?
    public let video: Video?
    public let voice: Voice?
    public let videoNote: VideoNote?
    public let caption: String?
    public let newChatMembers: [User]?
    public let leftChatMember: User?
    public let newChatTitle: String?
    public let newChatPhoto: [PhotoSize]?
    public let deleteChatPhoto: Bool?
    public let groupChatCreated: Bool?
    public let supergroupChatCreated: Bool?
    public let channelChatCreated: Bool?
    public let migrateToChatId: Int64?
    public let migrateFromChatId: Int64?
    public let hasMediaSpoiler: Bool?

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case messageThreadId = "message_thread_id"
        case from
        case date
        case chat
        case senderChat = "sender_chat"
        case forwardFrom = "forward_from"
        case forwardFromChat = "forward_from_chat"
        case forwardFromMessageId = "forward_from_message_id"
        case forwardSignature = "forward_signature"
        case forwardSenderName = "forward_sender_name"
        case forwardDate = "forward_date"
        case isTopicMessage = "is_topic_message"
        case editDate = "edit_date"
        case mediaGroupId = "media_group_id"
        case authorSignature = "author_signature"
        case text
        case entities
        case captionEntities = "caption_entities"
        case audio
        case document
        case animation
        case game
        case photo
        case sticker
        case video
        case voice
        case videoNote = "video_note"
        case caption
        case newChatMembers = "new_chat_members"
        case leftChatMember = "left_chat_member"
        case newChatTitle = "new_chat_title"
        case newChatPhoto = "new_chat_photo"
        case deleteChatPhoto = "delete_chat_photo"
        case groupChatCreated = "group_chat_created"
        case supergroupChatCreated = "supergroup_chat_created"
        case channelChatCreated = "channel_chat_created"
        case migrateToChatId = "migrate_to_chat_id"
        case migrateFromChatId = "migrate_from_chat_id"
        case hasMediaSpoiler = "has_media_spoiler"
    }
}

// MARK: - Equatable

extension TelegramMessage: Equatable {
    public static func == (lhs: TelegramMessage, rhs: TelegramMessage) -> Bool {
        // Compare messageId for uniqueness
        guard lhs.messageId == rhs.messageId else {
            return false
        }

        // Compare text content, treating nil as equal to nil
        switch (lhs.text, rhs.text) {
        case (nil, nil):
            return true
        case let (leftText?, rightText?):
            return leftText == rightText
        default:
            return false
        }
    }
}

// MARK: - Init

extension TelegramMessage {
    public init(text: String, userId: Int) {
        messageId = Int.random(in: 1 ... 1000)
        messageThreadId = nil
        from = .init(
            id: userId, isBot: false, firstName: "John", lastName: "Doe", username: "johndoe",
            languageCode: "en")
        date = Int(Date().timeIntervalSince1970)
        chat = .init(id: 0, type: .privateChat)
        senderChat = nil
        forwardFrom = nil
        forwardFromChat = nil
        forwardFromMessageId = nil
        forwardSignature = nil
        forwardSenderName = nil
        forwardDate = nil
        isTopicMessage = nil
        editDate = nil
        mediaGroupId = nil
        authorSignature = nil
        self.text = text
        entities = nil
        captionEntities = nil
        audio = nil
        document = nil
        animation = nil
        game = nil
        photo = nil
        sticker = nil
        video = nil
        voice = nil
        videoNote = nil
        caption = nil
        newChatMembers = nil
        leftChatMember = nil
        newChatTitle = nil
        newChatPhoto = nil
        deleteChatPhoto = nil
        groupChatCreated = nil
        supergroupChatCreated = nil
        channelChatCreated = nil
        migrateToChatId = nil
        migrateFromChatId = nil
        hasMediaSpoiler = nil
    }
}

public extension Int {
    static let UserID = 0
    static let BotUserId = 1
}
