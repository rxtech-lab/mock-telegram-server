import Vapor

struct RegisterWebhookRequest: Content {
    let url: String
}

struct RegisterWebhookResponse: Content {}

struct CloseResponse: Content {
    var ok: Bool = true
    var result: Bool = true
}

public struct Webhook: Identifiable, Sendable {
    public let id: UUID
    public let url: URL
    public let chatroomId: Int
    /**
     Whether the webhook endpoint is reachable
    */
    public var isActive: Bool = false

    /// The last error that occurred when calling the webhook
    public var lastError: String?

    /// The last time the webhook was called
    public var lastUpdate: Date?

    public init(id: UUID, chatroomId: Int, url: URL) {
        self.id = id
        self.url = url
        self.chatroomId = chatroomId
    }

    public init(chatroomId: Int, url: URL) {
        self.chatroomId = chatroomId
        self.url = url
        self.id = UUID()
    }
}
