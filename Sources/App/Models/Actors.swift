actor UpdateManager {
    static let shared = UpdateManager()
    private var updates: [Message] = []

    private init() {}

    func reset() {
        updates = []
    }

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

    func reset() {
        chatId = 0
        messageId = 0
        messages = []
    }

    func addMessage(_ message: Message) -> Message {
        var message = message
        if message.messageId == nil {
            message.messageId = messageId
            messageId += 1
        }
        messages.append(message)
        return message
    }

    func getMessageById(_ id: Int) -> Message? {
        return messages.first { $0.messageId == id }
    }

    func updateMessageById(_ id: Int, message: Message) {
        guard let index = messages.firstIndex(where: { $0.messageId == id }) else {
            return
        }
        var newMessage = message
        newMessage.updateCount += 1
        messages[index] = newMessage
    }
}
