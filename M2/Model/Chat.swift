//
//  Chat.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import DifferenceKit

/// A model class for a chat between two users.
class Chat: Codable {
    /// The id of the chat.
    let id: Int
    /// The user of the chat that uses the current device which the app is running on.
    let thisUser: String
    /// The other user of the chat.
    let otherUser: String
    
    /// If this user if has actively opened the chat.
    var thisUserIsActive = false
    /// If the other user has actively opened the chat.
    var otherUserIsActive = false
    
    /// If the chat is complete.
    var isComplete: Bool {
        return thisUserIsActive && otherUserIsActive
    }
    
    init(id: Int, thisUser: String, otherUser: String) {
        self.id = id
        self.thisUser = thisUser
        self.otherUser = otherUser
    }
    
    /// Starts a chat.
    ///
    /// - Parameter completion: If the backend call completed successfully.
    func startChat(completion: @escaping (Bool) -> Void) {
        // 1. Sets the active chat in the backend through a backend call
        // 2. Invokes the completion with success.
        // 3. If success, sends a matching stream command to the backend.
        BackendWorker.shared.request(ChatRequestEndpoint.setActiveChat(requester: thisUser, receiver: otherUser)) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self, let success = try? result.get() else {
                completion(false)
                return
            }
            completion(success)
            
            if success {
                StreamWorker.shared.send(streamable: OutgoingChangedActiveStatusStreamCommand(requester: self.thisUser, receiver: self.otherUser, isOnline: true))
            }
        }
    }
    
    /// Leaves a chat.
    ///
    /// - Parameter completion: If the backend call completed successfully.
    func leaveChat(completion: @escaping (Bool) -> Void) {
        // 1. Sets the active chat in the backend through a backend call
        // 2. Invokes the completion with success
        // 3. If success, sends a matching stream command to the backend
        BackendWorker.shared.request(ChatRequestEndpoint.setActiveChat(requester: thisUser, receiver: "")) { (result: Result<Bool, Error>) in
            guard let success = try? result.get() else {
                completion(false)
                return
            }
            completion(success)
            
            if success {
                StreamWorker.shared.send(streamable: OutgoingChangedActiveStatusStreamCommand(requester: self.thisUser, receiver: self.otherUser, isOnline: false))
            }
        }
    }

    /// Checks if a chat is complete.
    ///
    /// - Parameter completion: If the backend call completed successfully.
    func checkIfIsComplete(completion: @escaping (Bool) -> Void) {
        // 1. Gets the active chat for this user from the backend
        // 2. Gets the active chat for the other user from the backend
        // 3. Invokes completion if both finished using DispatchGroups
        let group = DispatchGroup()
        group.enter()
        BackendWorker.shared.request(ChatRequestEndpoint.getActiveChat(username: thisUser)) {  [weak self] (result: Result<GetActiveChatResponse, Error>) in
            guard let self = self, let response = try? result.get() else {
                completion(false)
                group.leave()
                return
            }
            
            self.thisUserIsActive = response.activeChat == self.otherUser
            group.leave()
        }
        group.enter()
        BackendWorker.shared.request(ChatRequestEndpoint.getActiveChat(username: otherUser)) {  [weak self] (result: Result<GetActiveChatResponse, Error>) in
            guard let self = self, let response = try? result.get() else {
                completion(false)
                return
            }
            
            self.otherUserIsActive = response.activeChat == self.thisUser
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(self.isComplete)
        }
    }
}

// MARK: - Equatable
extension Chat: Equatable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Differentiable
extension Chat: Differentiable {
    // Boilerplate implementation for DifferenceKit
    
    var differenceIdentifier: Int {
        return self.id
    }
    
    func isContentEqual(to source: Chat) -> Bool {
        return self.id == source.id
    }
}
