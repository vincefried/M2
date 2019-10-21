//
//  PersistanceWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 12.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A worker class for handling persistance for variables
/// that are harmless from a safety point of view.
struct PersistanceWorker {
    /// The id of the currently signed in user.
    static var thisUserId: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "thisUserId")
        }
        
        get {
            return UserDefaults.standard.string(forKey: "thisUserId")
        }
    }
    
    /// The username of the currently signed in user.
    static var thisUserName: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "thisUserName")
        }
        
        get {
            return UserDefaults.standard.string(forKey: "thisUserName")
        }
    }
    
    /// The password of the currently signed in user.
    /// TODO: Save password in keychain instead of preferences.
    static var thisUserPass: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "thisUserPass")
        }
        
        get {
            return UserDefaults.standard.string(forKey: "thisUserPass")
        }
    }
    
    /// The device token of the currently signed in user.
    static var deviceToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceToken")
        }
        
        get {
            return UserDefaults.standard.string(forKey: "deviceToken")
        }
    }
}
