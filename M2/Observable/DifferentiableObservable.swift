//
//  DifferentiableObservable.swift
//  M2
//
//  Created by Vincent Friedrich on 17.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

import Foundation
import DifferenceKit

/// The closure to be invoked, containing an instance of the observable that it was invoked from.
public typealias DifferentiableClosure<T: Differentiable> = (_ observable: DifferentiableObservable<T>, _ changeset: StagedChangeset<[T]>?) -> Void
/// The observer that was bound to the Observable.
public typealias DifferentiableObserver = NSObject

/// A differentiable observable class for the implementation with DifferenceKit.
/// Can be bound and unbound to be observed by other classes.
public class DifferentiableObservable<T: Differentiable>: NSObject {
    /// The list of observers.
    private var observers: [(observer: DifferentiableObserver, closure: DifferentiableClosure<T>)]
    
    override init() {
        observers = []
    }
    
    /// Binds an observer to the observable.
    ///
    /// - Parameters:
    ///   - closure: The closure to be executed if the observable changes.
    ///   - observer: The observer to be bound.
    public func bind(closure: @escaping DifferentiableClosure<T>, observer: DifferentiableObserver) {
        self.observers.append((observer, closure))
    }
    
    /// Unbinds an observer from the observable.
    ///
    /// - Parameter observer: The observer to be unbound.
    public func unbind(observer: Observer) {
        self.observers.removeAll { $0.observer == observer }
    }
    
    /// Notifies all registered observers for a change and differentiates between old an new data using DifferenceKit's StagedChangeset.
    public func notifyObservers(oldData: [T]? = nil, newData: [T]? = nil) {
        guard let oldData = oldData, let newData = newData else {
            self.observers.forEach { [unowned self] (_, observable: (DifferentiableObservable, StagedChangeset<[T]>?) -> Void) in
                observable(self, nil)
            }
            return
        }
        
        self.observers.forEach { [unowned self] (_, observable: (DifferentiableObservable, StagedChangeset<[T]>?) -> Void) in
            let changeset = StagedChangeset(source: oldData, target: newData)
            observable(self, changeset)
        }
    }
}

