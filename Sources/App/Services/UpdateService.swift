actor UpdateManager {
    // Singleton instance of UpdateManager
    static let shared = UpdateManager()

    /**
     * Array of updates
     * Key: chatroomId
     * Value: Array of messages
     */
    private var updates: [Int: [Message]] = [:]

    // Private initializer to prevent multiple instances
    private init() {}

    // Resets the updates array to an empty state
    func reset() {
        updates = [:]
    }

    func reset(chatroomId: Int) {
        updates[chatroomId] = []
    }

    // Adds a new update to the updates array
    func addUpdate(chatroomId: Int, _ update: Message) {
        updates[chatroomId, default: []].append(update)
    }

    // Retrieves all updates and clears the updates array
    func getUpdates(chatroomId: Int) -> [Message] {
        let updates = self.updates[chatroomId, default: []]
        self.updates[chatroomId] = []
        return updates
    }
}
