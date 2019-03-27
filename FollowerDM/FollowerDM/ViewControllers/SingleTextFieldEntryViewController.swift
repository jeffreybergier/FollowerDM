
//
//  SingleTextFieldEntryViewController.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 22/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

@objc protocol TextEntryFieldViewControllerDelegate {
    /// Validate the user entered string. Enables and Disables the "Confirm" button based on BOOL return value.
    @objc optional func validateTextEntry(rawString: String, controller: SingleTextFieldEntryViewController) -> Bool
    /// Indicates the user tapped the 'Confirm' button. The ViewController will not dismiss automatically.
    func userConfirmedTextEntry(rawString: String, controller: SingleTextFieldEntryViewController)
    /// Indicates the user tapped the 'Cancel' button. The ViewController will not dismiss automatically.
    func userCancelledTextEntry(controller: SingleTextFieldEntryViewController)
}

class SingleTextFieldEntryViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var confirmButton: (AnyObject & EnableDisableObject)?

    weak var delegate: TextEntryFieldViewControllerDelegate?
    var initialTextFieldValue: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // move the popover delegate to us if present so we can control dismissal
        self.popoverPresentationController!.delegate = self
        // configure our view
        self.textField?.text = self.initialTextFieldValue
        self.textChanged(nil)
    }

    @IBAction private func confirmButtonTapped(_ sender: Any) {
        let rawString = self.textField?.text ?? ""
        self.delegate?.userConfirmedTextEntry(rawString: rawString, controller: self)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.delegate?.userCancelledTextEntry(controller: self)
    }

    @IBAction private func textChanged(_ sender: Any?) {
        let rawString = self.textField?.text ?? ""
        let isValid = self.delegate?.validateTextEntry?(rawString: rawString, controller: self) ?? true
        self.confirmButton?.JSB_isEnabled = isValid ? true : false
    }

    override var preferredContentSize: CGSize {
        get {
            // it would be better to find an exact way to calculate the height
            // but for now, checking `isAccessibilityCategory` is acceptable
            let height: CGFloat = self.view.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 96 : 56
            return CGSize(width: 320, height: height)
        }
        set {}
    }
}

extension SingleTextFieldEntryViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.delegate?.userCancelledTextEntry(controller: self)
        return false
    }
}

@objc protocol EnableDisableObject {
    var JSB_isEnabled: Bool { get set } // strange name needed because of compiler error
}

extension UIButton: EnableDisableObject {
    var JSB_isEnabled: Bool {
        get { return self.isEnabled }
        set { self.isEnabled = newValue }
    }
}
extension UIBarButtonItem: EnableDisableObject {
    var JSB_isEnabled: Bool {
        get { return self.isEnabled }
        set { self.isEnabled = newValue }
    }
}
