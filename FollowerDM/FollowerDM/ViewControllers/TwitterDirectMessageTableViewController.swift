//
//  TwitterDirectMessageTableViewController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 19/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

class TwitterDirectMessageTableViewController: UITableViewController, TwitterDirectMessageControllable {

    private let remoteUserChatCellIdentifier = "ChatBubbleLeftCell"
    private let localUserChatCellIdentifier = "ChatBubbleRightCell"

    // manages receiving and sending messages
    private var messageController: TwitterDirectMessageControllerProtocol?

    // MARK: Manage Authentication and Data

    func configure(remote: TwitterUsername, authToken: TwitterAuthToken) {
        self.messageController = FakeData_TwitterDirectMessageController(remote: remote, authToken: authToken)
        self.messageController?.dataChanged = { [unowned self] in
            // unowned is needed here or else we will create a retain cycle
            // unowned is more appropriate than weak because this instance of TwitterDirectMessageControllerProtocol
            // can never exist longer than this view controller unless there is a mistake somewhere
            self.tableView.reloadData()
            self.scrollToNewestMessage()
        }
    }

    // MARK: Manage user input

    func validate(rawMessageString: String) -> Bool {
        let trimmedString = DirectMessage.messageCompatibleString(fromRawString: rawMessageString)
        return trimmedString != nil ? true : false
    }

    func userTappedSendButton(withRawMessageString rawMessageString: String) {
        guard let trimmedString = DirectMessage.messageCompatibleString(fromRawString: rawMessageString) else { return }
        self.messageController?.send(message: trimmedString)
    }

    // MARK: Manage Tableview

    private func scrollToNewestMessage() {
        guard let data = self.messageController?.data else { return }
        let endIndex = data.index(before: data.endIndex)
        let lastIndexPath = IndexPath(row: endIndex, section: 0)
        self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageController?.data.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get the data and cell and crash if either is missing
        // this method should never be called if there is no data
        // but in production, it may make sense to have this fail silently.
        let data = self.messageController!.data[indexPath.row]
        let identifier = data.remoteTwitterUsername != nil ? self.remoteUserChatCellIdentifier : self.localUserChatCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ImageTitleSubtitleLabelTableViewCell
        cell.setDirectMessage(data)
        return cell
    }
}

/// Extension to our 'dumb' cell class that allows it to be populated with our model object
fileprivate extension ImageTitleSubtitleLabelTableViewCell {
    fileprivate func setDirectMessage(_ message: DirectMessage) {
        self.titleLabel?.text = message.message
        switch message.uploadDownloadStatus {
        case .success:
            self.primaryImageView?.alpha = 1
        case .failure, .inProgress:
            self.primaryImageView?.alpha = 0.5
        }
    }
}
