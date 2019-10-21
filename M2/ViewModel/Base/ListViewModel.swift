//
//  ListViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 10.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A base class for a ViewModel for lists.
class ListViewModel<DataModelType, ViewModelType: CellViewModel<DataModelType>> {
    /// A list of the given ViewModelType.
    var data: [ViewModelType] = []
    
    /// A given provider.
    var provider: Observable
    
    /// The provider, with which the ListViewModel should be initialized with.
    ///
    /// - Parameter provider: A provider.
    init(provider: Observable) {
        self.provider = provider
    }
}
