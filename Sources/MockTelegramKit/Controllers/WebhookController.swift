import Vapor

struct WebhookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("setWebhook", use: registerWebhook)
    }

    @Sendable
    func registerWebhook(req _: Request) async throws -> RegisterWebhookResponse {
        return RegisterWebhookResponse()
    }
}
