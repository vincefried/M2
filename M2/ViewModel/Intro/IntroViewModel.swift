//
//  IntroViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 28.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A delegate for the IntroViewModel.
protocol IntroViewModelDelegate: class {
    /// Indicates that the UI needs to be updated.
    func updateUINeeded()
    /// Indicates that the login did finish.
    ///
    /// - Parameter success: If the login did finish successfully.
    func didFinish(success: Bool)
}

/// A ViewModel for the IntroViewController.
protocol IntroViewModel {
    /// The title text.
    var title: String { get }
    /// The secondary title label text.
    var titleLabelText: String { get }
    /// The done button text.
    var doneButtonTitle: String { get }
    /// If the done button should be enabled.
    var isDoneButtonEnabled: Bool { get }
    /// The error text.
    var errorText: String { get }
    /// If the error label should be hidden.
    var isErrorLabelHidden: Bool { get }
    /// If the activity indicator should be shown.
    var isActivityIndicatorShown: Bool { get }
    
    /// A delegate for the IntroViewModel
    var delegate: IntroViewModelDelegate? { get set }
    
    /// Handles a tap on the action button.
    ///
    /// - Parameters:
    ///   - username: The username text which the button tap was invoked with.
    ///   - password: The password text which the button tap was invoked with.
    func handleActionButtonTapped(username: String, password: String)
    /// Handles a change of the username text field.
    ///
    /// - Parameter text: The new text of the username text field.
    func handleUsernameTextFieldChanged(text: String)
}

extension IntroViewModel {
    // Boilerplate implementation of protocol
    
    func handleUsernameTextFieldChanged(text: String) { }
}
