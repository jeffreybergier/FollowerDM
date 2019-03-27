//
//  TwitterModels.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import Foundation

enum UnauthenticatedCredentials {
    case credentials(username: String, password: String)
    case applicationOnly
}

/// Don't construct these yourself, they are returned by the ModelController objects
struct TwitterAuthToken {
    /// if set to NIL, the token is for `applicationOnly` authentication
    var twitterUsername: String?
    var authToken: String
}

struct TwitterUsername {
    var shortName: String
    var displayName: String
    var profileImageURL: URL

    /// Attempts to convert user input into a valid twitter username.
    /// This implementation is quick and dirty and not complete.
    static func twitterShortNameCompatibleString(fromRawString raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed2 = trimmed.replacingOccurrences(of: " ", with: "")
        let trimmed3 = trimmed2.replacingOccurrences(of: "@", with: "")
        if trimmed3 == "" {
            return nil
        } else {
            return trimmed3
        }
    }
}

struct DirectMessage {
    /// If set, this is a remote user message
    /// If NIL, this message is from the local user
    var remoteTwitterUsername: String?
    var message: String
    var uploadDownloadStatus: Status
    enum Status {
        case inProgress, success, failure(Error)
    }

    /// precondition: Use the provided `messageCompatibleStringFromRawString:` static method
    /// To create a valid string or else init will fatalError if an invalid string is provided
    init(message: String, remoteTwitterUsername: String?, uploadDownloadStatus: Status) {
        let trimmed = DirectMessage.messageCompatibleString(fromRawString: message)
        precondition(trimmed == message)
        self.message = message
        self.remoteTwitterUsername = remoteTwitterUsername
        self.uploadDownloadStatus = uploadDownloadStatus
    }

    /// Takes a raw string from the user and cleans it
    /// Trims leading and trailing white space characters
    /// Also returns NIL if the string contains no visible characters.
    static func messageCompatibleString(fromRawString raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed == "" {
            return nil
        } else {
            return trimmed
        }
    }
}
