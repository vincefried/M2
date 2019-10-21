//
//  JSONDecoder+Custom.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

extension JSONDecoder {
    /// Decodes an Alamofire DataResponse to a given type.
    ///
    /// - Parameters:
    ///   - type: The type to which the DataResponse's content should be parsed to.
    ///   - response: The response the should be parsed.
    /// - Returns: A Swift.Result with the parsed object or an error.
    func decodeResponse<T: Decodable>(type: T.Type, response: DataResponse<Data>) -> Swift.Result<T, Error> {
        // If data is nil, return error
        guard let data = response.data else {
            return .failure(response.error!)
        }
        
        // Try parsing the content
        do {
            return .success(try decode(type, from: data))
        } catch (let error) {
            return .failure(error)
        }
    }
}
