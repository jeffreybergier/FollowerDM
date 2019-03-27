
//
//  SimpleTwitterFollowerRetrieverController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 21/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import Foundation

enum SimpleTwitterFollowerRetrieverController: TwitterFollowerRetrieverControllerProtocol {

    private static let followerURLComponents = URLComponents(string: "https://api.twitter.com/1.1/friends/list.json")!

    static func retrieveFollowers(forTwitterUsername username: String,
                                  authToken: TwitterAuthToken,
                                  completionHandler: @escaping (Result<[TwitterUsername], JSONDownloadError>) -> Void)
    {
        if let _ = authToken.twitterUsername {
            fatalError("TODO: Implement the request as an authorized user")
        } else {
            // build the URL
            var components = self.followerURLComponents
            components.queryItems = [
                URLQueryItem(name: "screen_name", value: username),
                URLQueryItem(name: "cursor", value: "-1"),
                URLQueryItem(name: "count", value: "200"),
            ]
            // build the request
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("Bearer " + authToken.authToken, forHTTPHeaderField: "Authorization")
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
                    let result = TwitterUsername.usernames(fromJSONDictionary: jsonDictionary)
                    completionHandler(result)
                }
            }
            // start the network request
            task.resume()
        }
    }
}

extension TwitterUsername {
    static func usernames(fromJSONDictionary jsonDictionary: NSDictionary) -> Result<[TwitterUsername], JSONDownloadError> {
        guard let usersArray = jsonDictionary["users"] as? NSArray else {
            return .failure(.desiredInformationMissingFromJSON)
        }
        let usernames = usersArray.compactMap() { user -> TwitterUsername? in
            guard
                let user = user as? NSDictionary,
                let username = user["screen_name"] as? String,
                let displayName = user["name"] as? String,
                let imageURLString = user["profile_image_url_https"] as? String,
                let imageURL = URL(string: imageURLString)
            else { return nil }
            return TwitterUsername(shortName: username, displayName: displayName, profileImageURL: imageURL)
        }
        return .success(usernames)
    }
}

