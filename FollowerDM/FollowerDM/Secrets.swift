//
//  Secrets.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 2019/03/27.
//  Copyright © 2019 Jeffrey Bergier. All rights reserved.
//

import Foundation

extension SimpleTwitterAuthTokenController {
    /// Never ever check API keys into a Github repo!
    /// This is for demonstration only
    static let base64EncodedConsumerSecret: String = { fatalError("Put in your own auth token") }()
}
