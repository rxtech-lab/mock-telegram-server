import Vapor

public struct SendChatActionResponse: Content {
    public var ok: Bool = true
    public var result: Bool = true

    public init(ok: Bool, result: Bool) {
        self.ok = ok
        self.result = result
    }
}

public struct SendChatActionRequest: Content {
    public var chatId: Int
    public var action: String

    public init(chatId: Int, action: String) {
        self.chatId = chatId
        self.action = action
    }

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case action
    }
}
