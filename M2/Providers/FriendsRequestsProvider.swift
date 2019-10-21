//
//  FriendsRequestsProvider.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A provider class, containing a list of friends requests for the current user.
class FriendsRequestsProvider: DifferentiableObservable<FriendsRequestResponse> {
    /// Shared instance for singleton usage.
    static let shared = FriendsRequestsProvider()
    
    override init() {
        super.init()
        
        // Bind the StreamWorker to the MessagesProvider
        StreamWorker.shared.unbind(observer: self)
        StreamWorker.shared.bind(delegate: self, observer: self)
    }
    
    /// The list of friends requests for the current user.
    /// Notifies the observers for a change.
    var friendsRequests: [FriendsRequestResponse] = [] {
        didSet {
            notifyObservers(oldData: oldValue, newData: friendsRequests)
        }
    }
    
    /// Gets the list of friends requests from the backend.
    func getFriendsRequests() {
        guard let currentUser = BackendWorker.shared.currentUser else { return }
        // Send the request to the backend
        let request = FriendsRequestsEndpoint.getFriendsRequests(requester: currentUser.username)
        BackendWorker.shared.request(request) { [weak self] (result: Result<[FriendsRequestResponse], Error>) in
            guard let responses = try? result.get() else { return }
            self?.friendsRequests = responses
        }
    }
    
    /// Deletes a friends request from the backend.
    ///
    /// - Parameter chat: The chat to delete the friends request for.
    func deleteFriendsRequest(for chat: Chat) {
        let request = FriendsRequestsEndpoint.deleteFriendsRequest(id: chat.id)
        // Send the request to the backend
        BackendWorker.shared.request(request) { [weak self] (result: Result<Bool, Error>) in
            guard let success = try? result.get() else { return }
            
            XCGLogger.default.debug(success)
            
            // If the request was sent successfully, send a command to the StreamWorker that the friends requests of the other user of the chat changed
            if success {
                StreamWorker.shared.send(streamable: OutgoingChangedFriendsRequestsStreamCommand(requester: chat.thisUser, receiver: chat.otherUser, changeType: .deleted))
                self?.getFriendsRequests()
            }
        }
    }
    
    /// Answers a friends request using a FriendsRequestResponse from the backend.
    ///
    /// - Parameters:
    ///   - friendsRequestResponse: The FriendsRequestResponse to be answered.
    ///   - state: The new state of the friends request.
    func answerFriendsRequest(friendsRequestResponse: FriendsRequestResponse, state: FriendsRequestResponse.FriendsRequestState) {
        guard let currentUser = BackendWorker.shared.currentUser else { return }
        let request = FriendsRequestsEndpoint.answerFriendsRequests(id: friendsRequestResponse.id,
                                                                    requester: currentUser.username,
                                                                    state: state)
        // Send the answering request to the backend
        BackendWorker.shared.request(request) { [weak self] (result: Result<Bool, Error>) in
            // If the request was sent successfully, send a command to the StreamWorker that the friends requests of the other user of the chat changed
            if case .success(true) = result {
                StreamWorker.shared.send(streamable: OutgoingChangedFriendsRequestsStreamCommand(requester: friendsRequestResponse.receiver,
                                                                                                 receiver: friendsRequestResponse.requester,
                                                                                                 changeType: state == .accepted
                                                                                                    ? .accepted
                                                                                                    : .declined))
                self?.getFriendsRequests()
            }
        }
    }
    
    /// Sends a friends request to the backend.
    ///
    /// - Parameters:
    ///   - requester: The requester of the friends request.
    ///   - receiver: The receiver of the friends request.
    ///   - completion: The finished completion.
    func sendFriendsRequest(requester: String, receiver: String, completion: @escaping (Bool) -> Void) {
        let request = FriendsRequestsEndpoint.sendFriendsRequests(requester: requester, receiver: receiver)
        // Send the request to the backend
        BackendWorker.shared.request(request) { (result: Result<Bool, Error>) in
            guard let success = try? result.get() else {
                completion(false)
                return
            }
            // If the request was sent successfully, send a command to the StreamWorker that the friends requests of the other user of the chat changed
            StreamWorker.shared.send(streamable: OutgoingChangedFriendsRequestsStreamCommand(requester: requester, receiver: receiver, changeType: .sent))
            // Invoke completion
            completion(success)
        }
    }
}

// MARK: - StreamWorkerDelegate
extension FriendsRequestsProvider: StreamWorkerDelegate {
    func streamDidReceiveChangedFriendsRequests(username: String) {
        // Get new list of friends requests when the StreamWorker notifies about a friends requests change
        getFriendsRequests()
    }
}
