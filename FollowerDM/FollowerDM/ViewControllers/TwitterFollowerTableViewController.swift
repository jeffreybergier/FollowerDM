//
//  TwitterFollowerTableViewController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

class TwitterFollowerTableViewController: UITableViewController {

    private let cellIdentifier = "UsernameCell"

    // Change these types to "swap out" the model controllers
    // This can be used to test with fake data
    private var loginController: TwitterAuthTokenControllerProtocol.Type = SimpleTwitterAuthTokenController.self
    private let dataRetriever: TwitterFollowerRetrieverControllerProtocol.Type = SimpleTwitterFollowerRetrieverController.self

    // Data displayed in the table
    private var data: [TwitterUsername] = []

    // The user we are loading the followers for
    private var currentQuery: String = "tim_cook"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView() // hides the row separators until data loads
        self.refreshFollowerList()
    }

    // MARK: Manage Auth and Loading Data

    private func refreshFollowerList() {
        // set the title to loading
        self.title = "Loading…"
        // a closure we're going to execute after we get an authentication token
        let retrieveFollowers: (TwitterAuthToken) -> Void = { token in
            self.dataRetriever.retrieveFollowers(forTwitterUsername: self.currentQuery, authToken: token) { result in
                switch result {
                case .success(let data):
                    self.data = data
                    self.tableView.reloadData()
                    self.title = "@" + self.currentQuery
                case .failure(let error):
                    print(error)
                }
            }
        }
        // check if we already have a token stored
        // if not, refresh the token
        if let token = self.loginController.existingToken(forUsername: nil) {
            retrieveFollowers(token)
        } else {
            self.loginController.refreshToken(unauthenticatedCredentials: .applicationOnly) { result in
                switch result {
                case .success(let token):
                    retrieveFollowers(token)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    // MARK: Manage transition to DM Chat

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let navVC = segue.destination as? UINavigationController,
            let vc = navVC.viewControllers.first as? SingleTextFieldEntryViewController
        {
            vc.delegate = self
            vc.initialTextFieldValue = "@" + self.currentQuery
        } else if
            let authToken = self.loginController.existingToken(forUsername: nil),
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell),
            let destVC = segue.destination as? TwitterDirectMessageViewController
        {
            destVC.configure(remote: self.data[indexPath.row], authToken: authToken)
        }
    }

    // MARK: Manage the TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get the cell. Crash if its the wrong type of cell
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! ImageTitleSubtitleLabelTableViewCell
        // get the data and populate the cell
        let data = self.data[indexPath.row]
        cell.setTwitterUsername(data)
        // provide the configured cell to the tableview
        return cell
    }
}

/// Extension to our 'dumb' cell class that allows it to be populated with our model object
fileprivate extension ImageTitleSubtitleLabelTableViewCell {
    fileprivate func setTwitterUsername(_ username: TwitterUsername) {
        // populate the cell with our data
        self.titleLabel?.text = "@" + username.shortName
        self.subtitleLabel?.text = username.displayName
        self.primaryImageView?.image = nil // clear out the image because we need to download a new one

        // Downloading the image is asynchronous
        // The unique identifier is how we'll check if the cell was recycled before the image was done downloading
        self.uniqueIdentifier = username.shortName
        UIImage.image(atRemoteURL: username.profileImageURL) { result in
            guard self.uniqueIdentifier == username.shortName else { return }
            switch result {
            case .success(let image):
                self.primaryImageView?.image = image
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension TwitterFollowerTableViewController: TextEntryFieldViewControllerDelegate {
    func validateTextEntry(rawString: String, controller: SingleTextFieldEntryViewController) -> Bool {
        return TwitterUsername.twitterShortNameCompatibleString(fromRawString: rawString) != nil
    }
    func userConfirmedTextEntry(rawString: String, controller: SingleTextFieldEntryViewController) {
        let username = TwitterUsername.twitterShortNameCompatibleString(fromRawString: rawString)
        self.currentQuery = username ?? ""
        self.refreshFollowerList()
        controller.dismiss(animated: true, completion: nil)
    }
    func userCancelledTextEntry(controller: SingleTextFieldEntryViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
