//
//  ChatsListViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A delegate for the ChatsListViewModel.
protocol ChatsListViewModelDelegate: class {
    /// Indicates that the UI needs to be updated.
    func updateUINeeded()
}

/// A ViewModel for the ChatsViewController.
class ChatsListViewModel: DifferentiableObservableListViewModel<Chat, ChatsCellViewModel> {
    /// A provider for the chats.
    private let chatsProvider: ChatsProvider
    
    /// A delegate for the ChatsListViewModel.
    weak var delegate: ChatsListViewModelDelegate?
    
    /// The value of the badge for the number of open friends requests.
    var badgeValue: String?
    
    init(chatsProvider: ChatsProvider) {
        self.chatsProvider = chatsProvider
        super.init(provider: chatsProvider)
        // Bind changes of the friends requests to update the badge value
        FriendsRequestsProvider.shared.unbind(observer: self)
        FriendsRequestsProvider.shared.bind(closure: { [weak self] _, _ in
            let friendsRequests = FriendsRequestsProvider.shared.friendsRequests
            // Set badge value to number of open friends requests
            self?.badgeValue = friendsRequests.count > 0 ? "\(friendsRequests.count)" : nil
            // Indicate that the UI needs to be updated
            self?.delegate?.updateUINeeded()
        }, observer: self)
    }
    
    deinit {
        FriendsRequestsProvider.shared.unbind(observer: self)
    }
    
    /// Loads the chats from its provider and maps them to instances of ChatsCellViewModel.
    func loadData() {
        if let chats = chatsProvider.chats {
            data = chats.map(ChatsCellViewModel.init)
        }
    }
    
    /// Updates new chats data to instances of ChatsCellViewModel.
    ///
    /// - Parameter newData: The new chats data.
    func updateData(_ newData: [Chat]) {
        data = newData.map(ChatsCellViewModel.init)
    }
    
    /// Handles a delete action for a chat.
    ///
    /// - Parameter index: The index in the list of chats that the delete action was invoked to.
    func handleDeleteChat(at index: Int) {
        // Get the chat out of the chats list
        guard let chatToDelete = chatsProvider.chats?[index] else { return }
        // Delete the friends request for the given chat
        FriendsRequestsProvider.shared.deleteFriendsRequest(for: chatToDelete)
    }
    
    /// Handles a logout button press.
    ///
    /// - Parameter completion: The completion after the logout call finished.
    func handleLogout(completion: @escaping (Bool) -> Void) {
        // Get the currently logged in user
        guard let user = BackendWorker.shared.currentUser else { return }
        // Log the user out using the user provider
        UsersWorker.logout(user: user, completion: completion)
    }
}
