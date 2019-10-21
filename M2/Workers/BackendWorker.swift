//
//  LoginWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// A delegate for the backend worker.
protocol BackendWorkerDelegate: class {
    /// Gets called when the authorization status did change.
    ///
    /// - Parameter isSignedIn: If the user is currently signed in.
    func authDidChange(_ isSignedIn: Bool)
}

/// A worker class for sending HTTP-requests to the backend.
class BackendWorker {
    /// Shared instance for singleton usage.
    static let shared = BackendWorker()
    
    /// A type for representing a host.
    ///
    /// - local: localhost
    /// - hetzner: production server without domain
    /// - production: future production server with domain, not yet available
    enum HostType: String {
        case local = "http://localhost"
        case production = "PLACEHOLDER"
    }
    
    /// The host type
    static let hostType: HostType = .production
    
    /// If the user is currently signed in.
    var isSignedIn: Bool = false {
        didSet {
            delegate?.authDidChange(isSignedIn)
        }
    }
    
    /// If the backend is reachable
    var isReachable: Bool = true
    
    /// A delegate for the BackendWorker
    weak var delegate: BackendWorkerDelegate?
    
    /// The currently logged in user.
    /// No user is logged in, if nil.
    var currentUser: User? {
        didSet {
            PersistanceWorker.thisUserId = currentUser?.id.uuidString
            PersistanceWorker.thisUserName = currentUser?.username
            PersistanceWorker.thisUserPass = currentUser?.password
        }
    }
    
    init() {
        if let uuidString = PersistanceWorker.thisUserId,
            let uuid = UUID(uuidString: uuidString),
            let username = PersistanceWorker.thisUserName,
            let password = PersistanceWorker.thisUserPass {
            currentUser = User(id: uuid, username: username, password: password)
            isSignedIn = true
        }
    }
    
    /// Downloads a file from a given endpoint using Alamofire.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to download from.
    ///   - filename: The file name of the file to download.
    ///   - progressClosure: A closure for a download progress.
    ///   - completion: Gets called if the download completed.
    func download(_ endpoint: Endpoint,
                  filename: String,
                  progressClosure: ((Progress) -> Void)? = nil,
                  completion: ((_ result: Swift.Result<Data, Error>) -> Void)? = nil) {
        Alamofire.download(endpoint,
                           parameters: endpoint.parameters,
                           to: DownloadRequest.suggestedDownloadDestination(for: .documentDirectory))
            .downloadProgress { progress in
                progressClosure?(progress)
            }.responseData { response in
                if let data = response.result.value {
                    XCGLogger.default.debug("data \(data)")
                    completion?(.success(data))
                } else {
                    guard let error = response.error else {
                        completion?(.failure(NSError(domain: "Unknown error", code: 0)))
                        return
                    }
                    completion?(.failure(error))
                }
        }
    }
    
    /// Uploads a file to a given endpoint using Alamofire.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to upload to.
    ///   - fileName: The file name of the file to upload.
    ///   - mimeType: The mime type of the file to upload.
    ///   - data: The file to upload as data representation.
    ///   - progressClosure: A closure for an upload progress.
    ///   - completion: Gets called if the upload completed.
    func upload(endpoint: Endpoint,
                fileName: String,
                mimeType: String,
                data: Data,
                progressClosure: ((Progress) -> Void)? = nil,
                completion: ((_ result: Swift.Result<Void, Error>) -> Void)? = nil) {
        // Add Headers
        let headers = [
            "Content-Type":"multipart/form-data;",
        ]
        
        // Fetch Request
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: mimeType)
        }, usingThreshold: UInt64.init(),
           to: endpoint,
           method: .post,
           headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString(completionHandler: { response in
                    switch response.result {
                    case .success:
                        completion?(.success(()))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
                upload.uploadProgress { progressClosure?($0) }
            case .failure(let encodingError):
                completion?(.failure(encodingError))
            }
        })
    }
    
    /// Sends a HTTP-request to a given endpoint.
    /// The http-method and parameters are taken from the given endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to send the request to.
    ///   - completion: Gets called if the request completed.
    func request<T: Codable>(_ endpoint: Endpoint,
                             completion: ((_ result: Swift.Result<T, Error>) -> Void)? = nil) {
        Alamofire
            .request(endpoint,
                     method: endpoint.method,
                     parameters: endpoint.parameters)
            .responseData { response in
                let decoded = JSONDecoder().decodeResponse(type: T.self, response: response)
                
                switch decoded {
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            if let success = true as? T {
                                completion?(.success(success))
                            } else {
                                completion?(.failure(error))
                            }
                        } else {
                            let error = NSError(domain: response.error?.localizedDescription ?? "", code: statusCode)
                            completion?(.failure(error))
                        }
                    } else {
                        completion?(.failure(error))
                    }
                default:
                    completion?(decoded)
                }
        }
    }
}
