import Vapor

struct RegisterWebhookRequest: Content {
    let url: String
}

struct RegisterWebhookResponse: Content {}
