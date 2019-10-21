//
//  ChatsProvider.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A diffenrentiable and observable provider class, containting a list of instances of Chat models.
class ChatsProvider: DifferentiableObservable<Chat> {
    /// The list of instances of Chat models.
    /// Notifies the observers on a change.
    var chats: [Chat]? {
        didSet {
            notifyObservers(oldData: oldValue, newData: chats)
        }
    }
    
    /// An instance of the friends requests provider.
    private let friendsRequestsProvider = FriendsRequestsProvider.shared
    
    override init() {
        super.init()
        
        // Bind to friends requests provider to reload chats on friends requests change.
        friendsRequestsProvider.unbind(observer: self)
        friendsRequestsProvider.bind(closure: { [weak self] _,_ in
            self?.getChats()
        }, observer: self)
    }
    
    deinit {
        friendsRequestsProvider.unbind(observer: self)
    }
    
    /// Gets all chats for the current user.
    ///
    /// - Parameter completion: The finished completion.
    func getChats(completion: ((_ chats: Result<[Chat], Error>) -> Void)? = nil) {
        guard let currentUser = BackendWorker.shared.currentUser else { return }
        
        let request = ChatEndpoint.getChats(requester: currentUser.username)
        BackendWorker.shared.request(request) { [weak self] (result: Result<[FriendsRequestResponse], Error>) in
            guard let self = self else {  return }
            
            switch result {
            case .success(let responses):
                self.chats = responses.map {
                    // Try the backend result with user a and user b in both ways, because you don't know if this user was the requester or the receiver of the friends request that the chat will be based on.
                    var thisUsername: String = ""
                    var otherUsername: String = ""
                    
                    if $0.requester == currentUser.username {
                        thisUsername = $0.requester
                        otherUsername = $0.receiver
                    } else {
                        thisUsername = $0.receiver
                        otherUsername = $0.requester
                    }
                    
                    return Chat(id: $0.id, thisUser: thisUsername, otherUser: otherUsername)
                }
                
                if let chats = self.chats {
                    completion?(.success(chats))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
