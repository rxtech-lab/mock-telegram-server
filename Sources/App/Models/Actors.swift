actor UpdateManager {
    static let shared = UpdateManager()
    private var updates: [Message] = []

    private init() {}

    func addUpdate(_ update: Message) {
        updates.append(update)
    }

    func getUpdates() -> [Message] {
        let updates = self.updates
        self.updates = []
        return updates
    }
}

actor ChatManager {
    static let shared = ChatManager()
    private(set) var chatId = 0
    private var messageId = 0
    private(set) var messages: [Message] = []

    private init() {}

    func addMessage(_ message: Message) -> Message {
        var message = message
        message.messageId = messageId
        messages.append(message)
        messageId += 1
        return message
    }

    func getMessageById(_ id: Int) -> Message? {
        return messages.first { $0.messageId == id }
    }

    func updateMessageById(_ id: Int, message: Message) {
        guard let index = messages.firstIndex(where: { $0.messageId == id }) else {
            return
        }
        messages[index] = message
    }
}
