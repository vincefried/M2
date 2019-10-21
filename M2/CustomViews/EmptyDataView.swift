//
//  EmtyDataView.swift
//  M2
//
//  Created by Vincent Friedrich on 01.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A delegate for EmptyDataView.
protocol EmptyDataViewDelegate: class {
    /// Gets called when the user pressed the action button.
    func didPressButton()
}

/// A custom subclass of UIStackView for the use of a placeholder view.
class EmptyDataView: UIStackView {

    /// The ViewModel for this view.
    var viewModel: EmptyDataViewModel? {
        didSet {
            setupView()
        }
    }
    
    /// The delegate of this view.
    weak var delegate: EmptyDataViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Sets the view and all of its styling properties up.
    private func setupView() {
        guard let viewModel = viewModel else { return }
        
        // UIStackView styling
        self.axis = .vertical
        self.spacing = 32
        
        // Add a title label
        let label = UILabel()
        label.text = viewModel.title
        label.textColor = .lightGray
        label.font = UIFont(name: "Futura-Medium", size: 20)
        label.textAlignment = .center
        self.addArrangedSubview(label)
        
        // Add a subtitle label if specified
        if let subtitle = viewModel.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = .lightGray
            subtitleLabel.font = UIFont(name: "Futura-Medium", size: 16)
            subtitleLabel.textAlignment = .center
            self.addArrangedSubview(subtitleLabel)
        }
        
        // Add an action button if specified
        if let buttonTitle = viewModel.buttonTitle {
            let button = RoundedButton()
            button.setTitle(buttonTitle, for: .normal)
            button.backgroundColor = UIColor(named: "complementary")
            button.tintColor = UIColor(named: "primary")
            button.setTitleColor(UIColor(named: "primary"), for: .normal)
            button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 17)
            button.cornerRadius = 15
            self.addArrangedSubview(button)
            
            button.width(min: 150, priority: .required, isActive: true)
            button.height(40)
            button.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        }
    }
    
    /// Gets called when the user pressed the action button and invokes the matching delegate call.
    @objc private func pressedButton() {
        delegate?.didPressButton()
    }
}
