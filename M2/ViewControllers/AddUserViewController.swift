//
//  AddUserViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UIViewController for adding a user as a friend.
class AddUserViewController: UIViewController {
    /// The ViewModel for the AddUserViewController.
    var viewModel: AddUserViewModel?
    
    /// A label for the view's title.
    @IBOutlet weak var titleLabel: UILabel!
    /// A textfield for allowing the user to search for a username.
    @IBOutlet weak var searchTextfield: RoundedTextfield!
    /// A label that indicates if a user for found for the given username.
    @IBOutlet weak var userExistsLabel: UILabel!
    /// A button to send a friends request to the given user.
    @IBOutlet weak var sendButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        viewModel = AddUserViewModel(friendsRequestsProvider: FriendsRequestsProvider.shared)
        viewModel?.delegate = self
        
        updateUI()
    }
    
    /// Sets up the UINavigationBar.
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .compact)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(dismissViewController))
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        title = viewModel.title
        titleLabel.text = viewModel.titleLabelText
        userExistsLabel.isHidden = !viewModel.showsExistsLabel
        userExistsLabel.text = viewModel.existsLabelText
        sendButton.setTitle(viewModel.buttonTitle, for: .normal)
        userExistsLabel.textColor = viewModel.extistsLabelColor
    }
    
    /// Dismisses the current ViewController.
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    /// Gets called if the content of the user search textfield did change.
    ///
    /// - Parameter sender: The user search textfield.
    @IBAction func textfieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel?.handleSearchTextChanged(text: text)
    }
    
    /// Gets called if the send friends request button was tapped.
    ///
    /// - Parameter sender: The send friends request button.
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = searchTextfield.text else { return }
        viewModel?.handeSendButtonTapped(username: text)
    }
}

// MARK: - AddUserViewModelDelegate
extension AddUserViewController: AddUserViewModelDelegate {
    func updateUINeeded() {
        updateUI()
    }
    
    func didFinish(success: Bool) {
        guard success else { return }
        dismiss(animated: true)
    }
}
