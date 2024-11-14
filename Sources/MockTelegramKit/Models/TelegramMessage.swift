import Foundation
import Vapor

public struct User: Content, Sendable {
    let id: Int
    let isBot: Bool
    let firstName: String
    let lastName: String?
    let username: String?
    let languageCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case isBot = "is_bot"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case languageCode = "language_code"
    }
}

public struct MessageEntity: Content, Sendable {
    let type: MessageEntityType
    let offset: Int
    let length: Int
    let url: String?
    let user: User?
    let language: String?
    let customEmojiId: String?

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
    let fileId: String
    let fileUniqueId: String
    let duration: Int
    let performer: String?
    let title: String?
    let mimeType: String?
    let fileSize: Int?
    let thumb: PhotoSize?

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
    let fileId: String
    let fileUniqueId: String
    let width: Int
    let height: Int
    let duration: Int
    let thumb: PhotoSize?
    let mimeType: String?
    let fileSize: Int?

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
    let fileId: String
    let fileUniqueId: String
    let duration: Int
    let mimeType: String?
    let fileSize: Int?

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
    let fileId: String
    let fileUniqueId: String
    let width: Int
    let height: Int
    let fileSize: Int?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case width
        case height
        case fileSize = "file_size"
    }
}

struct Document: Content {
    let fileId: String
    let fileUniqueId: String
    let thumb: PhotoSize?
    let fileName: String?
    let mimeType: String?
    let fileSize: Int?

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
    let fileId: String
    let fileUniqueId: String
    let width: Int
    let height: Int
    let duration: Int
    let thumb: PhotoSize?
    let fileName: String?
    let mimeType: String?
    let fileSize: Int?

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
    let title: String
    let description: String
    let photo: [PhotoSize]
    let text: String?
    let textEntities: [MessageEntity]?
    let animation: Animation?

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
    let fileId: String
    let fileUniqueId: String
    let type: StickerType
    let width: Int
    let height: Int
    let isAnimated: Bool
    let isVideo: Bool
    let thumb: PhotoSize?
    let emoji: String?
    let setName: String?
    let premiumAnimation: File?
    let maskPosition: MaskPosition?
    let customEmojiId: String?
    let fileSize: Int?

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

enum StickerType: String, Content {
    case regular
    case mask
    case customEmoji = "custom_emoji"
}

public struct VideoNote: Content {
    let fileId: String
    let fileUniqueId: String
    let length: Int
    let duration: Int
    let thumb: PhotoSize?
    let fileSize: Int?

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
    let point: String
    let xShift: Double
    let yShift: Double
    let scale: Double

    enum CodingKeys: String, CodingKey {
        case point
        case xShift = "x_shift"
        case yShift = "y_shift"
        case scale
    }
}

public struct File: Codable {
    let fileId: String
    let fileUniqueId: String
    let fileSize: Int?
    let filePath: String?

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case fileUniqueId = "file_unique_id"
        case fileSize = "file_size"
        case filePath = "file_path"
    }
}

public struct TelegramChat: Codable {
    let id: Int
    let type: ChatType

    enum ChatType: String, Codable {
        case privateChat = "private"
        case group
        case supergroup
        case channel
    }
}

public struct CallbackQuery: Content {
    let id: String
    let from: User
    let message: TelegramMessage?
    let inlineMessageId: String?
    let chatInstance: String
    let data: String?
    let gameShortName: String?

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
    let messageId: Int
    let messageThreadId: Int?
    let from: User?
    let date: Int
    let chat: TelegramChat
    let senderChat: TelegramChat?
    let forwardFrom: User?
    let forwardFromChat: TelegramChat?
    let forwardFromMessageId: Int?
    let forwardSignature: String?
    let forwardSenderName: String?
    let forwardDate: Int?
    let isTopicMessage: Bool?
    let editDate: Int?
    let mediaGroupId: String?
    let authorSignature: String?
    let text: String?
    let entities: [MessageEntity]?
    let captionEntities: [MessageEntity]?
    let audio: Audio?
    let document: Document?
    let animation: Animation?
    let game: Game?
    let photo: [PhotoSize]?
    let sticker: Sticker?
    let video: Video?
    let voice: Voice?
    let videoNote: VideoNote?
    let caption: String?
    let newChatMembers: [User]?
    let leftChatMember: User?
    let newChatTitle: String?
    let newChatPhoto: [PhotoSize]?
    let deleteChatPhoto: Bool?
    let groupChatCreated: Bool?
    let supergroupChatCreated: Bool?
    let channelChatCreated: Bool?
    let migrateToChatId: Int64?
    let migrateFromChatId: Int64?
    let hasMediaSpoiler: Bool?

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
