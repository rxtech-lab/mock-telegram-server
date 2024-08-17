import Vapor

struct WebhookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("setWebhook", use: registerWebhook)
    }

    func registerWebhook(req: Request) async throws -> RegisterWebhookResponse {
        let body = try req.content.decode(RegisterWebhookRequest.self)

        return RegisterWebhookResponse()
    }
}
