//
//  LoginViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UIViewController for displaying a login.
class LoginViewController: UIViewController {
    /// A ViewModel for the contents of the LoginViewController.
    var viewModel: IntroViewModel?
    
    /// A label for displaying a secondary title.
    @IBOutlet weak var titleLabel: UILabel!
    /// A textfield for allowing text input for the username.
    @IBOutlet weak var usernameTextField: UITextField!
    /// A textfield for allowing text input for the password.
    @IBOutlet weak var passwordTextField: UITextField!
    /// A label for displaying an error.
    @IBOutlet weak var errorLabel: UILabel!
    /// A button for submitting the input.
    @IBOutlet weak var doneButton: UIButton!
    /// An activity indicator for indicating loading process at login.
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.delegate = self
        
        // Add gesture recognizer to hide textfields in tap anywhere in the view
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedView)))
        
        initCI()
        updateUI()
    }
    
    /// Gets invoked by the UITapGestureRecognizer added to the view.
    @objc private func tappedView() {
        // Hide all textfields if editing
        view.endEditing(true)
    }
    
    /// Initializes the CI and styles all views as necessary.
    private func initCI() {
        guard let userIcon = UIImage(named: "user"), let passIcon = UIImage(named: "pass") else { return }
        usernameTextField.setIcon(userIcon)
        passwordTextField.setIcon(passIcon)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitleColor(UIColor(named: "extraLightGray"), for: .disabled)
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        title = viewModel.title
        titleLabel.text = viewModel.titleLabelText
        errorLabel.text = viewModel.errorText
        doneButton.setTitle(viewModel.doneButtonTitle, for: .normal)
        errorLabel.isHidden = viewModel.isErrorLabelHidden
        doneButton.isEnabled = viewModel.isDoneButtonEnabled
        activityIndicatorView.isHidden = !viewModel.isActivityIndicatorShown
    }
    
    /// Gets called if the user tapped the login button.
    ///
    /// - Parameter sender: The login button.
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        viewModel?.handleActionButtonTapped(username: usernameTextField.text ?? "",
                                            password: passwordTextField.text ?? "")
    }
    
    /// Gets called if the user changed the content of the username textfield.
    ///
    /// - Parameter sender: The username textfield.
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        viewModel?.handleUsernameTextFieldChanged(text: sender.text ?? "")
    }
}

// MARK: - IntroViewModelDelegate
extension LoginViewController: IntroViewModelDelegate {
    func didFinish(success: Bool) {
        // Display an error alert if the login was unsuccessful
        if !success {
            let alertController = UIAlertController(title: "Fehler", message: "Nutzername oder Passwort existieren nicht oder sind falsch.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    
    func updateUINeeded() {
        updateUI()
    }
}
