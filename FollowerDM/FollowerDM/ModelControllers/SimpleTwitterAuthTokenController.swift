//
//  SimpleTwitterAuthTokenController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 21/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import Foundation

enum SimpleTwitterAuthTokenController: TwitterAuthTokenControllerProtocol {
    
    private static let tokenURL = URL(string: "https://api.twitter.com/oauth2/token")!

    private static var cachedToken: TwitterAuthToken?
    
    static func existingToken(forUsername username: String?) -> TwitterAuthToken? {
        return self.cachedToken
    }

    static func refreshToken(unauthenticatedCredentials: UnauthenticatedCredentials, completionHandler: @escaping (Result<TwitterAuthToken, JSONDownloadError>) -> Void) {
        switch unauthenticatedCredentials {
        case .credentials(_, _):
            fatalError("TODO: Implement login as a real user")
        case .applicationOnly:
            // build the request
            var request = URLRequest(url: self.tokenURL)
            request.httpMethod = "POST"
            request.addValue("Basic " + self.base64EncodedConsumerSecret, forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data("grant_type=client_credentials".utf8)
            // process the download
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    // if there's an error, bail immediately
                    if let error = error {
                        completionHandler(.failure(.cocoaError(error)))
                        return
                    }
                    // make sure we got a success response from the server
                    guard let response = response as? HTTPURLResponse, response.acceptableResponse else {
                        completionHandler(.failure(.unacceptableServerResponse))
                        return
                    }
                    // get the JSON
                    guard
                        let data = data,
                        let _jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                        let jsonDictionary = _jsonDictionary
                    else {
                        completionHandler(.failure(.dataNotConvertibleToJSONObject))
                        return
                    }
                    // get the needed info out of the JSON
                    guard
                        let tokenType = jsonDictionary["token_type"] as? String,
                        let bearerToken = jsonDictionary["access_token"] as? String,
                        tokenType == "bearer"
                    else {
                        completionHandler(.failure(.desiredInformationMissingFromJSON))
                        return
                    }
                    // success!
                    let authToken = TwitterAuthToken(twitterUsername: nil, authToken: bearerToken)
                    self.cachedToken = authToken
                    completionHandler(.success(authToken))
                }
            }
            // start the network request
            task.resume()
        }

    }

}
