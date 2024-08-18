actor ChatManager {
    static let shared = ChatManager()
    private(set) var chatId = 0
    private var messageId = 0
    private(set) var messages: [Int: [Message]] = [:]

    private init() {}

    /**
     * Resets the state.
     */
    func reset() {
        chatId = 0
        messageId = 0
        messages = [:]
    }

    /**
     * Resets the state for a specific chatroom.
     * - Parameter chatroomId: The chatroom ID.
     */
    func reset(chatroomId: Int) {
        messages[chatroomId] = []
    }

    func addMessage(chatroomId: Int, _ message: Message) -> Message {
        var message = message
        if message.messageId == nil {
            message.messageId = messageId
            messageId += 1
        }
        messages[chatroomId, default: []].append(message)
        return message
    }

    func getMessageById(chatroomId: Int, _ id: Int) -> Message? {
        return messages[chatroomId, default: []].first { $0.messageId == id }
    }

    func updateMessageById(chatroomId: Int, id: Int, message: Message) {
        guard let index = messages[chatroomId, default: []].firstIndex(where: { $0.messageId == id }) else {
            return
        }
        var newMessage = message
        newMessage.updateCount += 1
        messages[chatroomId, default: []][index] = newMessage
    }
}
