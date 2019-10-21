//
//  UsersProvider.swift
//  M2
//
//  Created by Vincent Friedrich on 12.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A worker class for handling user related backend requests.
class UsersWorker {
    /// Registers a user.
    ///
    /// - Parameters:
    ///   - user: The user to be registered.
    ///   - completion: The finished completion.
    static func register(user: User, completion: @escaping (Bool) -> Void) {
        let endpoint = UserEndpoint.register(id: UUID().uuidString, username: user.username, password: user.password, deviceToken: user.deviceToken)
        BackendWorker.shared.request(endpoint) { (result: Result<Bool, Error>) in
            guard case .success = result else {
                completion(false)
                return
            }
            
            BackendWorker.shared.currentUser = user
            BackendWorker.shared.isSignedIn = true
            
            StreamWorker.shared.open()
            
            let loginCommand = OutgoingLoginStreamCommand(user: user)
            StreamWorker.shared.send(streamable: loginCommand)
            
            completion(true)
        }
    }
    
    /// Logs in a user.
    ///
    /// - Parameters:
    ///   - user: The user to be logged in.
    ///   - completion: The finished completion.
    static func login(user: User, completion: @escaping (Bool) -> Void) {
        let request = UserEndpoint.login(username: user.username, password: user.password, deviceToken: user.deviceToken)
        BackendWorker.shared.request(request) { (result: Result<Bool, Error>) in
            switch result {
            case .success(let success):
                if !success {
                    completion(false)
                }
                
                BackendWorker.shared.currentUser = user
                BackendWorker.shared.isSignedIn = success
                
                StreamWorker.shared.open()
                
                let loginCommand = OutgoingLoginStreamCommand(user: user)
                StreamWorker.shared.send(streamable: loginCommand)
                
                completion(success)
            case .failure(let error):
                XCGLogger.default.error(error)
                completion(false)
            }
        }
    }
    
    /// Updates a device token for a given username.
    ///
    /// - Parameters:
    ///   - username: The username to update the device token for.
    ///   - deviceToken: The devicetoken.
    ///   - completion: The finished completion.
    static func updateDeviceToken(username: String, deviceToken: String, completion: ((Bool) -> Void)? = nil) {
        let request = UserEndpoint.updateDeviceToken(username: username, deviceToken: deviceToken)
        BackendWorker.shared.request(request) { (result: Result<Bool, Error>) in
            switch result {
            case .success(let success):
                completion?(success)
            case .failure:
                completion?(false)
            }
        }
    }
    
    /// Logs out a user.
    ///
    /// - Parameters:
    ///   - user: The user to be logged out.
    ///   - completion: The finished completion.
    static func logout(user: User, completion: @escaping (Bool) -> Void) {
        let request = UserEndpoint.logout(username: user.username, password: user.password)
        BackendWorker.shared.request(request) { (result: Result<Bool, Error>) in
            BackendWorker.shared.currentUser = nil
            BackendWorker.shared.isSignedIn = false
            
            PersistanceWorker.thisUserId = nil
            PersistanceWorker.thisUserName = nil
            PersistanceWorker.thisUserPass = nil
            
            StreamWorker.shared.close()
            
            if case .failure(let error) = result {
                XCGLogger.default.error(error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
