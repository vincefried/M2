//
//  FriendsRequestTableViewCell.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UITableViewCell for displaying a friends request entry in the FriendsRequestsViewController.
class FriendsRequestTableViewCell: UITableViewCell {
    /// The ViewModel for the FriendsRequestTableViewCell.
    /// Updates the UI when it gets set.
    var viewModel: FriendsRequestCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    /// A label for displaying the name of the friends request's requester.
    @IBOutlet weak var nameLabel: UILabel!
    /// A label for displaying the timestamp at which the friends request was issued.
    @IBOutlet weak var dateLabel: UILabel!
    /// A button for accepting the friends request.
    @IBOutlet weak var acceptButton: RoundedButton!
    /// A button for declining the friends request.
    @IBOutlet weak var declineButton: RoundedButton!
    /// A background view.
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCI()
        updateUI()
    }
    
    /// Initializes the CI and styles all views as necessary.
    private func initCI() {
        view.clipsToBounds = true
        
        view.layer.cornerRadius = 17.5
        view.layer.masksToBounds = false
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.nameLabelText
        dateLabel.text = viewModel.dateLabelText
        acceptButton.setTitle(viewModel.acceptButtonTitle, for: .normal)
        declineButton.setTitle(viewModel.declineButtonTitle, for: .normal)
    }
    
    /// Gets invoked if the user tapped on the accept button.
    ///
    /// - Parameter sender: The button which the tap was sent from.
    @IBAction func acceptRequest(_ sender: Any) {
        viewModel?.handleAcceptButtonTapped()
    }
    
    /// Gets invoked if the user tapped on the decline button.
    ///
    /// - Parameter sender: The button which the tap was sent from.
    @IBAction func declineRequest(_ sender: Any) {
        viewModel?.handleDeclineButtonTapped()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        view.backgroundColor = highlighted ? UIColor(named: "background") : UIColor(named: "complementary")
        backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}
