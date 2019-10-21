//
//  DifferentiableObservableViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 17.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import DifferenceKit

/// A base class for a differentiable and observable version of the ListViewModel using DifferenceKit.
class DifferentiableObservableListViewModel<DataModelType: Differentiable, ViewModelType: CellViewModel<DataModelType>>: NSObject {
    
    /// A list of ViewModelType.
    var data: [ViewModelType] = []
    
    /// A differentiable and observable provider.
    var provider: DifferentiableObservable<DataModelType>
    
    init(provider: DifferentiableObservable<DataModelType>) {
        self.provider = provider
    }
    
    /// Binds a given observer to changes in the contained provider.
    ///
    /// - Parameters:
    ///   - closure: The closure that should be invoked be the changes.
    ///   - observer: The observer which is owner of the closure.
    func bind(closure: @escaping DifferentiableClosure<DataModelType>, observer: Observer) {
        provider.bind(closure: closure, observer: observer)
    }
    
    /// Unbinds an observer.
    ///
    /// - Parameter observer: The observer that should be unbound.
    func unbind(observer: Observer) {
        provider.unbind(observer: observer)
    }
}
