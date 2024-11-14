import Vapor

struct RegisterWebhookRequest: Content {
    let url: String
}

struct RegisterWebhookResponse: Content {}

struct CloseResponse: Content {
    var ok: Bool = true
    var result: Bool = true
}
