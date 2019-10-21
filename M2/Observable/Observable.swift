//
//  Observable.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// The closure to be invoked, containing an instance of the observable that it was invoked from.
public typealias Closure = (_ observable: Observable) -> Void
/// The observer that was bound to the Observable.
public typealias Observer = NSObject

/// An observable class.
/// Can be bound and unbound to be observed by other classes.
public class Observable: NSObject {
    /// The list of observers.
    private var observers: [(observer: Observer, closure: Closure)]
    
    override init() {
        observers = []
    }
    
    /// Binds an observer to the observable.
    ///
    /// - Parameters:
    ///   - closure: The closure to be executed if the observable changes.
    ///   - observer: The observer to be bound.
    public func bind(closure: @escaping Closure, observer: Observer) {
        self.observers.append((observer, closure))
    }
    
    /// Unbinds an observer from the observable.
    ///
    /// - Parameter observer: The observer to be unbound.
    public func unbind(observer: Observer) {
        self.observers.removeAll { $0.observer == observer }
    }
    
    /// Notifies all registered observers for a change.
    public func notifyObservers() {
        self.observers.forEach { [unowned self] (_, observable: Closure) in
            observable(self)
        }
    }
}
