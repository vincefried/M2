//
//  EmptyDataViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 01.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A base protocol for the ViewModel for EmtyDataView.
protocol EmptyDataViewModel {
    /// The title of the view.
    var title: String { get }
    /// The subtitle of the view. Doesn't get displayed if nil.
    var subtitle: String? { get }
    /// The button title of the view's action button. Doesn't get displayed if nil.
    var buttonTitle: String? { get }
}

extension EmptyDataViewModel {
    // Boilerplate initialization of subtitle and button title.
    
    var subtitle: String? {
        return nil
    }
    var buttonTitle: String? {
        return nil
    }
}
