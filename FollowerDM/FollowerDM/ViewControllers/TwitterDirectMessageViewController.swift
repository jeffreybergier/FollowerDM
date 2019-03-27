//
//  TwitterDirectMessageViewController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 20/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

class TwitterDirectMessageViewController: UIViewController, TwitterDirectMessageControllable {

    // MARK: Handle Direct Message TableViewController Child VC

    private var childMessageTableViewController: (UITableViewController & TwitterDirectMessageControllable)?
    private var dmConfigurationDataForChildVC: (TwitterUsername, TwitterAuthToken)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField()
        if let config = self.dmConfigurationDataForChildVC {
            self.title = "💬 " + config.0.displayName
            self.childMessageTableViewController?.configure(remote: config.0, authToken: config.1)
        }
    }

    func configure(remote: TwitterUsername, authToken: TwitterAuthToken) {
        self.dmConfigurationDataForChildVC = (remote, authToken)
    }

    func validate(rawMessageString: String) -> Bool {
        return self.childMessageTableViewController?.validate(rawMessageString: rawMessageString) ?? false
    }

    func userTappedSendButton(withRawMessageString rawMessageString: String) {
        self.childMessageTableViewController?.userTappedSendButton(withRawMessageString: rawMessageString)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if let dest = dest as? UITableViewController & TwitterDirectMessageControllable {
            self.childMessageTableViewController = dest
        }
    }

    // MARK: Handle Chat Textbox

    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var sendButton: UIButton?
    @IBOutlet private weak var keyboardAdjascentView: UIView?
    @IBOutlet private weak var keyboardDismissedConstraint: NSLayoutConstraint?
    @IBOutlet private weak var keyboardPresentedConstraint: NSLayoutConstraint?
    private var keyboardAnimator = KeyboardAnimator()
    private let constraintPadding: CGFloat = 8

    private func configureTextField() {
        self.sendButton?.isEnabled = false
        self.keyboardAnimator.animateAlongsideKeyboardChanges = { [unowned self] change in
            // unowned is needed here or else we will create a retain cycle
            // unowned is more appropriate than weak because this instance of KeyboardAnimator
            // can never exist longer than this view controller unless there is a mistake somewhere
            switch change {
            case .presenting(let height), .changing(let height):
                self.keyboardDismissedConstraint?.isActive = false
                self.keyboardPresentedConstraint?.constant = height + self.constraintPadding
                self.keyboardPresentedConstraint?.isActive = true
            case .dismissing:
                self.keyboardPresentedConstraint?.isActive = false
                self.keyboardDismissedConstraint?.isActive = true
            }
            self.view.layoutIfNeeded()
        }
    }

    @IBAction private func sendButtonTapped(_ sender: UIButton) {
        // get the message
        let rawMessageString = self.textField?.text ?? ""
        // reset the UI
        self.textField?.text = ""
        self.sendButton?.isEnabled = false
        self.view.endEditing(true)
        // send the message
        self.userTappedSendButton(withRawMessageString: rawMessageString)
    }

    /// Enable or disable the send button based on the validity of the text
    /// that the user has typed in
    @IBAction private func textFieldValueChanged(_ sender: UITextField) {
        let rawMessageString = self.textField?.text ?? ""
        let isValid = self.validate(rawMessageString: rawMessageString)
        self.sendButton?.isEnabled = isValid ? true : false
    }
}
