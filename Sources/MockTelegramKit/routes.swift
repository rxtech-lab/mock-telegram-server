import Vapor

func routes(app: Application) throws {
    try app.register(collection: WebhookController())
    try app.register(collection: TelegramController())
    try app.register(collection: ChatController())
}
