//
//  AddUserViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A delegate for the AddUserViewModel.
protocol AddUserViewModelDelegate: class {
    /// Indicates that the UI needs to be updated.
    func updateUINeeded()
    /// Indicates that the sent request did finish.
    ///
    /// - Parameter success: If the request finished with success.
    func didFinish(success: Bool)
}

/// A ViewModel for the AddUserViewController.
class AddUserViewModel {
    /// The ViewController's title.
    let title = "Nutzer hinzufügen"
    /// The ViewController's secondary title.
    let titleLabelText = "Nach Nutzer suchen"
    /// The title of the action button.
    let buttonTitle = "    Anfrage senden    "
    
    /// If the label that indicates if the username already exists should be shown.
    var showsExistsLabel = false
    /// The color for the label that indicates if the username already exists.
    var extistsLabelColor = UIColor(named: "correct")
    /// The text for the label that indicates if the username already exists.
    var existsLabelText = "Nutzer gefunden"
    
    /// A delegate for the AddUserViewModel.
    weak var delegate: AddUserViewModelDelegate?
    
    /// The provider for the friends requests.
    private let friendsRequestsProvider: FriendsRequestsProvider
    
    init(friendsRequestsProvider: FriendsRequestsProvider) {
        self.friendsRequestsProvider = friendsRequestsProvider
    }
    
    /// Handles the text change of the search text and controls the label that indicates if the username already exists.
    ///
    /// - Parameter text: The new text of the search text field.
    func handleSearchTextChanged(text: String) {
        BackendWorker.shared.request(UserEndpoint.checkUsername(username: text)) { [weak self] (result: Result<CheckUsernameResponse, Error>) in
            // Try to get a result of the response
            guard let response = try? result.get() else { return }
            let exists = !response.isAvailable
            // Control the label, matching the response availability
            self?.existsLabelText = exists ? "Nutzer gefunden" : "Nutzer nicht gefunden"
            self?.extistsLabelColor = exists ? UIColor(named: "correct") : UIColor(named: "warning")
            self?.showsExistsLabel = exists
            // Indicate that the UI needs to be updated
            self?.delegate?.updateUINeeded()
        }
    }
    
    /// Handles the a tap on the send button.
    ///
    /// - Parameter username: The given username.
    func handeSendButtonTapped(username: String) {
        BackendWorker.shared.request(UserEndpoint.checkUsername(username: username)) { [weak self] (result: Result<Bool, Error>) in
            // Try to get a result of the response
            guard let isAvailable = try? result.get() else { return }
            let exists = !isAvailable
            // Control the label, matching the response availability
            self?.existsLabelText = exists ? "Nutzer gefunden" : "Nutzer nicht gefunden"
            self?.extistsLabelColor = exists ? UIColor(named: "correct") : UIColor(named: "warning")
            self?.showsExistsLabel = true
            // Indicate that the UI needs to be updated
            self?.delegate?.updateUINeeded()

            // Get the current user
            guard let currentUser = BackendWorker.shared.currentUser else { return }
            
            // Send the friends request for the username and indicate the the request finished if it did
            self?.friendsRequestsProvider.sendFriendsRequest(requester: currentUser.username, receiver: username) { [weak self] success in
                self?.delegate?.didFinish(success: success)
            }
        }
    }
}

