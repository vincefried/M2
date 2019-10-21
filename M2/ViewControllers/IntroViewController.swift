//
//  IntroViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 28.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UIViewController for displaying a landing screen at first app launch.
class IntroViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    /// Sets up the navigation bar styling.
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .compact)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    /// Sets the destination ViewControllers' ViewModels accordingly.
    ///
    /// - Parameters:
    ///   - segue: The segue.
    ///   - sender: The button which the segue was trigger from.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let loginViewController = segue.destination as? LoginViewController else { return }

        switch segue.identifier {
        case "showSignIn":
            loginViewController.viewModel = SignInIntroViewModel()
        case "showCreateAccount":
            loginViewController.viewModel = CreateAccountIntroViewModel()
        default:
            break
        }
    }
}
