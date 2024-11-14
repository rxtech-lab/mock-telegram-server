#if canImport(Combine)
    import Combine
#endif

/**
 * UpdateManager is responsible for managing message updates in chatrooms.
 * It is used in the telegram long-polling mode to store and retrieve updates.
 */
public actor UpdateManager {
    /// Singleton instance of UpdateManager that should be used throughout the app
    static let shared = UpdateManager()

    /// Dictionary storing updates for each chatroom
    /// Key: chatroomId - Unique identifier for each chatroom
    /// Value: Array of messages - Collection of pending updates for the chatroom
    private var updates: [Int: [Message]] = [:]

    /// Private initializer to enforce Singleton pattern
    private init() {}

    /// Resets all updates across all chatrooms to empty state.
    /// This will clear all pending updates from memory.
    public func reset() {
        updates = [:]
    }

    /// Resets updates for a specific chatroom.
    ///
    /// @param chatroomId The unique identifier of the chatroom to reset
    public func reset(chatroomId: Int) {
        updates[chatroomId] = []
    }

    /// Adds a new message update to a specific chatroom's update queue.
    /// If the chatroom doesn't exist in the updates dictionary, it will be created.
    ///
    /// @param chatroomId The unique identifier of the target chatroom
    /// @param update The message to be added to the updates queue
    public func addUpdate(chatroomId: Int, _ update: Message) {
        updates[chatroomId, default: []].append(update)
    }

    /// Retrieves all pending updates for a specific chatroom and clears them from the queue.
    /// This method follows a "read and clear" pattern to ensure updates are only processed once.
    ///
    /// @param chatroomId The unique identifier of the chatroom
    /// @return Array of pending Message updates for the specified chatroom
    public func getUpdates(chatroomId: Int) -> [Message] {
        let updates = self.updates[chatroomId, default: []]
        self.updates[chatroomId] = []
        return updates
    }
}
