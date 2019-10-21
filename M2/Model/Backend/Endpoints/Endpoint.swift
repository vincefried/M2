//
//  Endpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 13.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// A HTTP-endpoint of the backend.
protocol Endpoint: URLConvertible {
    /// The route of the HTTP-endpoint.
    var route: String { get }
    /// The url of the HTTP-endpoint as String.
    var urlString: String { get }
    /// The HTTP-method of the HTTP-endpoint.
    var method: HTTPMethod { get }
    /// The paramters of the HTTP-endpoint.
    var parameters: [String: Any] { get }
}

extension Endpoint {
    /// Converts the urlString of the HTTP-endpoint to a URL.
    ///
    /// - Returns: The converted URL.
    /// - Throws: Throws an error in conversion failed.
    func asURL() throws -> URL {
        guard let url = URL(string: urlString) else { fatalError("Invalid url") }
        return url
    }
    
    /// The route of the HTTP-endpoint.
    var route: String {
        return "/m2/"
    }
}
