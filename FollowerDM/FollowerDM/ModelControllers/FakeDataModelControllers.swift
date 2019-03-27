//
//  FakeDataModelControllers.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import Foundation

/// Provides an fake chat experience
/// Posts a new message from the remote user every 5 seconds
/// Simulates an 3 second upload time when the user submits a new message
class FakeData_TwitterDirectMessageController: TwitterDirectMessageControllerProtocol {

    private let remote: TwitterUsername
    private let authToken: TwitterAuthToken
    private lazy var fakeRemoteMessageTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [unowned self] timer in
        // if the last message was sent by the user, we want to echo the message twice
        // as per the specification provided as part of the test
        let message: String
        if let lastMessage = self.data.last, lastMessage.remoteTwitterUsername == nil {
            message = lastMessage.message + " " +  lastMessage.message
        } else {
            message = "Hi! 👋 This is a fake message. This is message #\(self.data.count + 1)"
        }
        let newMessage = DirectMessage(message: message, remoteTwitterUsername: self.remote.shortName, uploadDownloadStatus: .success)
        self.data += [newMessage]
        self.dataChanged?()
    }

    var dataChanged: (() -> Void)?
    private(set) var data: [DirectMessage] = []

    required init(remote: TwitterUsername, authToken: TwitterAuthToken) {
        self.remote = remote
        self.authToken = authToken
        _ = self.fakeRemoteMessageTimer // activate the timer
    }

    func send(message: String) {
        // create the new message
        // and tell our clients the data changed
        let newMessage = DirectMessage(message: message, remoteTwitterUsername: nil, uploadDownloadStatus: .inProgress)
        self.data += [newMessage]
        self.dataChanged?()

        // set this message index aside so that in 3 seconds,
        // we can change the upload status from `inProgress` to `success`
        self.indexesOfInProgressMessagesToComplete += [self.data.index(before: self.data.endIndex)]
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            timer.invalidate()
            // iterate through user posted messages to mark them as successfully uploaded
            self.indexesOfInProgressMessagesToComplete.forEach() { index in
                var data = self.data[index]
                data.uploadDownloadStatus = .success
                self.data[index] = data
            }
            self.indexesOfInProgressMessagesToComplete = []
            self.dataChanged?()
        }
    }

    private var indexesOfInProgressMessagesToComplete: [Int] = []

    deinit {
        // its our responsibility to invalidate the timer
        // otherwise the closure will leak and be called repeatedly forever
        self.fakeRemoteMessageTimer.invalidate()
    }
}

// MARK: Unused fake data controllers

enum FakeData_TwitterAuthTokenController: TwitterAuthTokenControllerProtocol {
    static func existingToken(forUsername username: String?) -> TwitterAuthToken? {
        return TwitterAuthToken(twitterUsername: username, authToken: "FakeToken")
    }
    static func refreshToken(unauthenticatedCredentials: UnauthenticatedCredentials,
                             completionHandler: @escaping (Result<TwitterAuthToken, JSONDownloadError>) -> Void) {}
}

enum FakeData_TwitterFollowerRetrieverController: TwitterFollowerRetrieverControllerProtocol {
    static func retrieveFollowers(forTwitterUsername username: String,
                                  authToken: TwitterAuthToken,
                                  completionHandler: @escaping (Result<[TwitterUsername], JSONDownloadError>) -> Void)
    {
        let fakeData: [TwitterUsername] = [
            TwitterUsername(shortName: "@isoiso_dosue", displayName: "いそいそ", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1012976759543816192/f2pDQjg6_bigger.jpg")!),
            TwitterUsername(shortName: "@kichikichi5956", displayName: "池田 友来", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/791598101618319360/jgVj8VuJ_bigger.jpg")!),
            TwitterUsername(shortName: "@withman_c", displayName: "withman", profileImageURL: URL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_bigger.png")!),
            TwitterUsername(shortName: "@kitty09050515", displayName: "kitty", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1018418806601814016/n8SwFZAy_bigger.jpg")!),
            TwitterUsername(shortName: "@shingu_1046", displayName: "TOSHI", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/887087541320433667/lS1fCsWQ_bigger.jpg")!),
            TwitterUsername(shortName: "@yuriruna2224", displayName: "ゆり", profileImageURL: URL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_bigger.png")!)
        ]
        completionHandler(.success(fakeData))
    }
}
