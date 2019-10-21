//
//  SignInIntroViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 28.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IntroViewModel for signing in to an exisiting account.
class SignInIntroViewModel: IntroViewModel {
    // Setting all variables matching the specified texts for creating an account
    var titleLabelText: String = "Willkommen zurück!"
    var title: String = "Anmelden"
    var doneButtonTitle: String = "    Anmelden    "
    var isDoneButtonEnabled: Bool = true
    var errorText: String = "Nutzername oder Passwort sind falsch"
    var isErrorLabelHidden: Bool = true
    var isActivityIndicatorShown = false
    
    /// A delegate for the IntroViewModel
    weak var delegate: IntroViewModelDelegate?
    
    func handleActionButtonTapped(username: String, password: String) {
        // Start loading state
        isActivityIndicatorShown = true
        isDoneButtonEnabled = false
        
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()

        // Initialize user with given credentials and try to login
        let user = User(id: UUID(), username: username, password: password)
        UsersWorker.login(user: user) { [weak self] success in
            if success {
                self?.delegate?.didFinish(success: success)
            } else {
                self?.delegate?.didFinish(success: false)
                self?.isActivityIndicatorShown = false
                self?.isDoneButtonEnabled = true
                self?.delegate?.updateUINeeded()
            }
        }
    }
}
