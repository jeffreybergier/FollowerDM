//
//  ModelControllerProtocols.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import Foundation

/// TwitterAuthTokenControllerProtocol
/// An object that implements this will be responsible for logging into Twitter
/// It will save the auth token to the keychain (or somewhere else secure)
/// It will retrieve them on next launch
protocol TwitterAuthTokenControllerProtocol {

    /// Retrieves the stored token from the keychain (or the decided upon storage location)
    /// If NIL, the token needs to be refreshed
    /// Does not verify the token is still valid (e.g. it could have expired)
    static func existingToken(forUsername username: String?) -> TwitterAuthToken?

    /// Refreshes the authtoken and saves it to the keychain (or somewhere else secure)
    /// Also returns the authtoken in the completion handler for use later
    /// `completionHandler` must be called on the Main Thread
    static func refreshToken(unauthenticatedCredentials: UnauthenticatedCredentials,
                      completionHandler: @escaping (Result<TwitterAuthToken, JSONDownloadError>) -> Void)
}

/// TwitterFollowerRetrieverControllerProtocol
/// An object that takes a twitter username and retrieves the list of followers
/// Object may choose to cache the results locally for quicker retrieval next time
protocol TwitterFollowerRetrieverControllerProtocol {

    /// Retrieves a list of followers of a particular user
    /// `completionHandler` must be called on the Main Thread
    static func retrieveFollowers(forTwitterUsername username: String,
                           authToken: TwitterAuthToken,
                           completionHandler: @escaping (Result<[TwitterUsername], JSONDownloadError>) -> Void)
}

/// TwitterDirectMessageControllerProtocol
/// Manages downloading messages as well as sending new messages
protocol TwitterDirectMessageControllerProtocol {
    init(remote: TwitterUsername, authToken: TwitterAuthToken)
    var data: [DirectMessage] { get }
    /// Executed whenever new messages are received from the server
    /// or the user sends a message
    /// In the future, this could be enhanced to tell which rows changed
    /// The the tableview could be updated in an animated way
    var dataChanged: (() -> Void)? { get set }
    func send(message: String)
}

/// TwitterDirectMessageControllable
/// Allows view controllers to pass messages to their child view controllers
protocol TwitterDirectMessageControllable: class {
    func configure(remote: TwitterUsername, authToken: TwitterAuthToken)
    func validate(rawMessageString: String) -> Bool
    func userTappedSendButton(withRawMessageString rawMessageString: String)
}
