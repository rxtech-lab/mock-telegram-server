#if canImport(Combine)
    import Combine
#endif

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
    private(set) var messages: [Int: [Message]] = [:]

    /// Storage for webhook URLs, keyed by chatroom ID
    /// Each chatroom can have one associated webhook URL
    private(set) var webhooks: [Int: String] = [:]

    /// Private initializer to enforce singleton pattern
    private init() {}

    #if canImport(Combine)
        /// Listenrs registered to receive updates when a new message is added
        public var messageListeners = PassthroughSubject<
            (charoomId: Int, message: Message), Never
        >()

        /// Listeners registered to receive reset events.
        /// The value returned by the listener is the chat room ID to reset. If it returns nil, then it is a global reset.
        public var resetListeners = PassthroughSubject<Int?, Never>()

        /// Listeners registered to receive webhook registration events.
        /// The value returned by the listener is a tuple containing the chat room ID and the webhook URL.
        public var registerWebhookListeners = PassthroughSubject<
            (chatroomId: Int, url: String), Never
        >()
    #endif

    /// Resets the entire chat manager state to initial values.
    /// This includes clearing all messages, webhooks, and resetting counters.
    public func reset() {
        chatId = 0
        messageId = 0
        messages = [:]
        webhooks = [:]
        #if canImport(Combine)
            resetListeners.send(nil)
        #endif
    }

    /// Resets the state for a specific chatroom by clearing its messages.
    /// Does not affect webhook registration or other chatrooms.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom to reset
    public func reset(chatroomId: Int) {
        messages[chatroomId] = []
        #if canImport(Combine)
            resetListeners.send(chatroomId)
        #endif
    }

    /// Registers a webhook URL for a specific chatroom.
    /// If a webhook already exists for the chatroom, it will be overwritten.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter url: The webhook URL to register
    public func registerWebhook(chatroomId: Int, url: String) {
        webhooks[chatroomId] = url
        #if canImport(Combine)
            registerWebhookListeners.send((chatroomId, url))
        #endif
    }

    /// Retrieves the registered webhook URL for a specific chatroom.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Returns: The registered webhook URL if it exists, nil otherwise
    public func getWebhook(chatroomId: Int) -> String? {
        return webhooks[chatroomId]
    }

    /// Retrieves all chatrooms that have registered webhooks.
    /// - Returns: An array of chatroom IDs with registered webhooks
    public func getAllChatrooms() -> [Int] {
        return Array(messages.keys)
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
            messageListeners.send((chatroomId, message))
        #endif
        return message
    }

    /// Retrieves a specific message from a chatroom by its ID.
    ///
    /// - Parameter chatroomId: The unique identifier of the chatroom
    /// - Parameter id: The unique identifier of the message
    /// - Returns: The message if found, nil otherwise
    public func getMessageById(chatroomId: Int, _ id: Int) -> Message? {
        return messages[chatroomId, default: []].first { $0.messageId == id }
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
        newMessage.updateCount += 1
        messages[chatroomId, default: []][index] = newMessage
    }
}