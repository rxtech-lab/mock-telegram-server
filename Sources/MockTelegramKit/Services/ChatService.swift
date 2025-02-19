import Foundation

#if canImport(Combine)
    import Combine
#endif
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public enum WebhookError: LocalizedError, Codable {
    case invalidURL
    case webhookNotFound(UUID)
    case webhookCallFailed(String)  // Changed to String to store error message

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid webhook URL. Your URL must be a valid url string."
        case let .webhookNotFound(id):
            return "Webhook with ID \(id) not found."
        case let .webhookCallFailed(errorMessage):
            return "Failed to call webhook: \(errorMessage)"
        }
    }

    // Custom coding keys
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case errorMessage
    }

    // Custom encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .invalidURL:
            try container.encode("invalidURL", forKey: .type)

        case .webhookNotFound(let id):
            try container.encode("webhookNotFound", forKey: .type)
            try container.encode(id, forKey: .id)

        case .webhookCallFailed(let errorMessage):
            try container.encode("webhookCallFailed", forKey: .type)
            try container.encode(errorMessage, forKey: .errorMessage)
        }
    }

    // Custom decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "invalidURL":
            self = .invalidURL

        case "webhookNotFound":
            let id = try container.decode(UUID.self, forKey: .id)
            self = .webhookNotFound(id)

        case "webhookCallFailed":
            let errorMessage = try container.decode(String.self, forKey: .errorMessage)
            self = .webhookCallFailed(errorMessage)

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid type value: \(type)"
            )
        }
    }
}

func callWebhook(chatroomId _: Int, webhook: Webhook, update: Update) async throws(WebhookError) {
    #if os(macOS)
        var request = URLRequest(url: webhook.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the update data
        guard let jsonData = try? JSONEncoder().encode(update) else {
            throw WebhookError.webhookCallFailed("Failed to encode update data")
        }
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WebhookError.webhookCallFailed("Failed to get HTTP response")
            }

            guard httpResponse.statusCode == 200 else {
                throw WebhookError.webhookCallFailed(
                    "Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch let error {
            throw WebhookError.webhookCallFailed(error.localizedDescription)
        }
    #endif
}

/**
 * Manages chat-related operations including message handling and webhook management.
 * Implements the Singleton pattern to ensure a single instance manages all chat operations.
 */
public actor ChatManager {
    /// Shared singleton instance of ChatManager
    public static let shared = ChatManager()

    /// Current chat ID counter, automatically incremented for new chats
    private(set) var chatId = 0

    /// Message ID counter used to assign unique IDs to new messages
    private var messageId = 0

    /// Storage for messages, keyed by chatroom ID
    /// The value is an array of Message objects for each chatroom
    private(set) var messages: [Int: [Message]] = [:] {
        didSet {
            #if canImport(Combine)
                messageListeners.send()
            #endif
        }
    }

    /// Storage for webhook URLs, keyed by chatroom ID
    /// Each chatroom can have one associated webhook URL
    private(set) var webhooks: [Int: Webhook] = [:] {
        didSet {
            #if canImport(Combine)
                registerWebhookListeners.send()
            #endif
        }
    }

    /// Storage for chat actions, keyed by chatroom ID
    private(set) var chatActions: [Int: String] = [:] {
        didSet {
            #if canImport(Combine)
                chatroomListeners.send()
            #endif
        }
    }

    /// Private initializer to enforce singleton pattern
    private init() {}

    public func setChatAction(chatroomId: Int, chatAction: String) {
        self.chatActions[chatroomId] = chatAction
    }

    public func load(
        messages: [Int: [Message]], webhooks: [Int: Webhook], chatId: Int, messageId: Int
    ) {
        self.messages = messages
        self.webhooks = webhooks
        self.chatId = chatId
        self.messageId = messageId
    }

    // save the state of the chat manager
    // @return: a tuple containing the messages, webhooks, chatId, and messageId
    public func save() -> ([Int: [Message]], [Int: Webhook], Int, Int) {
        return (messages, webhooks, chatId, messageId)

    }

    #if canImport(Combine)
        /// Listenrs registered to receive updates when a new message is added
        public var messageListeners = PassthroughSubject<
            Void, Never
        >()

        /// Listeners registered to receive reset events.
        /// The value returned by the listener is the chat room ID to reset. If it returns nil, then it is a global reset.
        public var resetListeners = PassthroughSubject<Void, Never>()

        /// Listeners registered to receive webhook registration events.
        public var registerWebhookListeners = PassthroughSubject<
            Void, Never
        >()

        public var chatroomListeners = PassthroughSubject<Void, Never>()
    #endif

    /// Resets the entire chat manager state to initial values.
    /// This includes clearing all messages, webhooks, and resetting counters.
    public func reset() {
        chatId = 0
        messageId = 0
        messages = [:]
        webhooks = [:]
        #if canImport(Combine)
            resetListeners.send()
        #endif
    }

    /// Resets the state for a specific chatroom by clearing its messages.
    /// Does not affect webhook registration or other chatrooms.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom to reset
    public func reset(chatroomId: Int) {
        messages[chatroomId] = []
        #if canImport(Combine)
            resetListeners.send()
        #endif
    }

    /// Adds a new message to a specific chatroom.
    /// If the message doesn't have an ID, assigns a new unique ID.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter message: The message to add
    /// - Returns: The message with an assigned ID if it didn't have one
    public func addMessage(chatroomId: Int, _ message: Message) -> Message {
        var message = message
        if message.messageId == nil {
            message.messageId = messageId
            messageId += 1
        }
        messages[chatroomId, default: []].append(message)
        #if canImport(Combine)
            chatroomListeners.send()
        #endif
        return message
    }

    /// Updates an existing message in a chatroom.
    /// Increments the update count of the message.
    /// If the message doesn't exist, the operation is ignored.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter id: The unique identifier of the message to update
    /// - Parameter message: The new message content
    public func updateMessageById(chatroomId: Int, id: Int, message: Message) {
        guard
            let index = messages[chatroomId, default: []].firstIndex(where: { $0.messageId == id })
        else {
            return
        }
        var newMessage = message
        newMessage.updateCount += messages[chatroomId, default: []][index].updateCount + 1
        messages[chatroomId, default: []][index] = newMessage
        #if canImport(Combine)
            messageListeners.send()
        #endif
    }
}

// MARK: - Webhook Management

extension ChatManager {
    /// Registers a webhook URL for a specific chatroom.
    /// If a webhook already exists for the chatroom, it will be overwritten.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter url: The webhook URL to register
    public func registerWebhook(chatroomId: Int, url: String) throws {
        guard let url = URL(string: url) else {
            throw WebhookError.invalidURL
        }
        webhooks[chatroomId] = Webhook(chatroomId: chatroomId, url: url)
    }

    /// Retrieves the registered webhook URL for a specific chatroom.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Returns: The registered webhook URL if it exists, nil otherwise
    public func getWebhook(chatroomId: Int) -> Webhook? {
        return webhooks[chatroomId]
    }

    /// Updates an existing webhook URL for a specific chatroom.
    public func updateWebhook(webhook: Webhook) throws -> Webhook {
        for (chatroomId, storedWebhook) in webhooks {
            if storedWebhook.id == webhook.id {
                webhooks[chatroomId] = webhook
                return webhook
            }
        }

        throw WebhookError.webhookNotFound(webhook.id)
    }

    /// * Deletes a webhook registration for a specific chatroom.
    /// * If the webhook doesn't exist, the operation is ignored.
    /// *
    /// * - Parameter id: The unique identifier of the webhook to delete
    public func deleteWebhook(id: UUID) {
        for (chatroomId, storedWebhook) in webhooks {
            if storedWebhook.id == id {
                webhooks[chatroomId] = nil
                return
            }
        }
    }

    /// Retrieves all webhooks registered across all chatrooms.
    public func getAllWebhooks() -> [Int: Webhook] {
        return webhooks
    }
}

// MARK: - Message Model

extension ChatManager {
    /// Retrieves all chatrooms that have registered webhooks.
    /// - Returns: An array of chatroom IDs with registered webhooks
    public func getAllChatrooms() -> [Int] {
        return Array(messages.keys)
    }

    public func sendMessage(chatroomId: Int, messageRequest: SendMessageRequest) async -> Message {
        var message = messageRequest.toMessage(userId: .UserID)
        message = addMessage(chatroomId: chatroomId, message)
        #if os(macOS)
            if var webhook = webhooks[chatroomId] {
                do {
                    try await callWebhook(
                        chatroomId: chatroomId, webhook: webhook,
                        update: Update(
                            updateId: 0, message: message.toTelegramMessage(),
                            callbackQuery: message.toCallbackQuery()))

                    webhook.lastError = nil
                    webhook.isActive = true
                } catch {
                    // update the webhook status
                    webhook.lastError = error.localizedDescription
                    webhook.isActive = false
                    // add an error to the message
                    // find message index
                    if let index = messages[chatroomId]?.firstIndex(where: {
                        $0.messageId == message.messageId
                    }) {
                        messages[chatroomId]?[index].error = error
                    }
                }
                webhook.lastUpdate = Date()
                webhooks[chatroomId] = webhook
            }
        #endif
        return message
    }

    public func createChatroom() -> Int {
        chatId += 1
        messages[chatId] = []
        #if canImport(Combine)
            chatroomListeners.send()
        #endif
        return chatId
    }

    public func deleteChatroom(chatroomId: Int) {
        messages[chatroomId] = nil
        #if canImport(Combine)
            chatroomListeners.send()
            if let webhook = webhooks[chatroomId] {
                deleteWebhook(id: webhook.id)
            }
        #endif
    }

    /// Retrieves a specific message from a chatroom by its ID.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter id: The unique identifier of the message
    /// - Returns: The message if found, nil otherwise
    public func getMessageById(chatroomId: Int, _ id: Int) -> Message? {
        return messages[chatroomId, default: []].first { $0.messageId == id }
    }

    public func getMessagesByChatroom(chatroomId: Int) -> [Message] {
        return messages[chatroomId, default: []]
    }

    #if os(macOS)
        public func clickOnMessageButton(
            chatroomId: Int, message: Message, button: InlineKeyboardButton
        )
            async
        {
            let newMessage = Message(
                messageId: message.messageId, text: message.text,
                callbackQuery: button.callbackData, userId: message.userId
            )
            if var webhook = webhooks[chatroomId] {
                do {
                    try await callWebhook(
                        chatroomId: chatroomId, webhook: webhook,
                        update: Update(
                            updateId: 0, message: newMessage.toTelegramMessage(),
                            callbackQuery: newMessage.toCallbackQuery()))
                    webhook.lastError = nil
                    webhook.isActive = true
                } catch {
                    // update the webhook status
                    webhook.lastError = error.localizedDescription
                    webhook.isActive = false
                    // add an error to the message
                    // find message index
                    if let index = messages[chatroomId]?.firstIndex(where: {
                        $0.messageId == message.messageId
                    }) {
                        messages[chatroomId]?[index].error = error
                    }
                }
                webhook.lastUpdate = Date()
                webhooks[chatroomId] = webhook
            }
        }
    #endif
}
