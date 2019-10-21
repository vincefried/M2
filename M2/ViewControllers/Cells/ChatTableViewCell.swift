//
//  ChatTableViewCell.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UITableViewCell for displaying a chat entry in the ChatsViewController.
class ChatTableViewCell: UITableViewCell {
    /// The ViewModel for the ChatTableViewCell.
    /// Updates the UI when it gets set.
    var viewModel: ChatsCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    /// The title label, displaying the name of the other chat user.
    @IBOutlet weak var titleLabel: UILabel!
    /// A circle view, displaying a background for the initials of the other chat user.
    @IBOutlet weak var circleView: UIView!
    /// A label, displaying the initials of the other chat user.
    @IBOutlet weak var initialsLabel: UILabel!
    /// A background view.
    @IBOutlet weak var view: UIView!
    /// A button for starting the chat.
    @IBOutlet weak var chatButton: RoundedButton!
    
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
        
        circleView.layer.cornerRadius = 25
        circleView.layer.masksToBounds = true
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        initialsLabel.text = viewModel.initialsText
        chatButton.setTitle(viewModel.buttonText, for: .normal)
        
        accessoryType = viewModel.accessoryType
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        view.backgroundColor = highlighted ? UIColor(named: "background") : UIColor(named: "complementary")
        backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}
