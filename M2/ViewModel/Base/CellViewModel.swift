//
//  ViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 08.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A base class for a ViewModel for a UITableViewCell of UICollectionViewCell, containing data.
class CellViewModel<T: Equatable> {
    let data: T
    
    init(data: T) {
        self.data = data
    }
}
