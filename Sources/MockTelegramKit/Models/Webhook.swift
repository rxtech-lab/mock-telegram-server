import Vapor

struct RegisterWebhookRequest: Content {
    let url: String
}

struct RegisterWebhookResponse: Content {}

struct CloseResponse: Content {
    var ok: Bool = true
    var result: Bool = true
}

public struct Webhook: Sendable {
    let url: URL
    /**
     Whether the webhook endpoint is reachable
    */
    var isActive: Bool = true

    /// The last error that occurred when calling the webhook
    var lastError: String?

    /// The last time the webhook was called
    var lastUpdate: Date?
}
