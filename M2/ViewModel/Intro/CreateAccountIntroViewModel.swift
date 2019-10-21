//
//  CreateAccountIntroViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 28.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IntroViewModel for the creating an account.
class CreateAccountIntroViewModel: IntroViewModel {
    // Setting all variables matching the specified texts for creating an account
    var titleLabelText: String = "Nutzername und Passwort wählen"
    var title: String = "Account erstellen"
    var doneButtonTitle: String = "    Fertig    "
    var isDoneButtonEnabled: Bool = true
    var errorText: String = "Nutzername ist bereits vergeben"
    var isErrorLabelHidden: Bool = true
    var isActivityIndicatorShown: Bool = false
    
    /// A delegate for the IntroViewModel
    weak var delegate: IntroViewModelDelegate?
    
    func handleActionButtonTapped(username: String, password: String) {
        // Start loading state
        isActivityIndicatorShown = true
        isDoneButtonEnabled = false
        
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
        
        // Check for the username
        BackendWorker.shared.request(UserEndpoint.checkUsername(username: username)) { [weak self] (result: Result<Bool, Error>) in
            // Continue if success, otherwise reset UI state
            guard case .success = result else {
                self?.isActivityIndicatorShown = false
                self?.isDoneButtonEnabled = true
                self?.delegate?.updateUINeeded()
                self?.delegate?.didFinish(success: false)
                return
            }
            
            // Create new user and register
            let user = User(id: UUID(), username: username, password: password)
            UsersWorker.register(user: user) { success in
                if success {
                    self?.delegate?.didFinish(success: true)
                } else {
                    self?.isActivityIndicatorShown = false
                    self?.isDoneButtonEnabled = true
                    self?.delegate?.updateUINeeded()
                    self?.delegate?.didFinish(success: false)
                }
            }
        }
    }
    
    func handleUsernameTextFieldChanged(text: String) {
        // Check username on every typed letter
        BackendWorker.shared.request(UserEndpoint.checkUsername(username: text)) { [weak self] (result: Result<Bool, Error>) in
            guard let isAvailable = try? result.get() else { return }
            self?.isErrorLabelHidden = isAvailable
            self?.delegate?.updateUINeeded()
        }
    }
}
