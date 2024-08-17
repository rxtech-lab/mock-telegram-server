import AnyCodable
import Foundation
import Vapor

struct TelegramController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post(":token", "getUpdates", use: getUpdates)
        routes.post(":token", "setMyCommands", use: setMyCommands)
        routes.post(":token", "sendMessage", use: sendMessage)
    }

    func sendMessage(req: Request) async throws -> SendTelegramMessageResponse {
        let body = try req.content.decode(SendTelegramMessageRequest.self)

        req.logger.notice("sendMessage called with message")
        _ = await ChatManager.shared.addMessage(body.toMessage())

        return SendTelegramMessageResponse(
            ok: true
        )
    }

    func getUpdates(req: Request) async throws -> GetTelegramUpdatesResponse {
        let updates = await UpdateManager.shared.getUpdates()
        if !updates.isEmpty {
            req.logger.notice("updates: \(updates)")
        }
        return GetTelegramUpdatesResponse(ok: true, result: updates.map { Update(updateId: 0, message: $0.toTelegramMessage()) })
    }

    func setMyCommands(req: Request) async throws -> SetTelegramMyCommandsResponse {
        let token = req.parameters.get("token")!
        req.logger.info("setMyCommands called with token: \(token)")
        // Implement setMyCommands logic here
        return SetTelegramMyCommandsResponse(ok: true)
    }
}
