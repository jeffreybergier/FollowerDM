//
//  KeyboardAnimator.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 20/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

/// KeyboardAnimator
/// Simple object that encapsulates the complexity of keyboard appearance
/// Provides animatable block that is automatically animated
/// To match the timing and curve of the keyboard animation
class KeyboardAnimator: NSObject {

    enum Change {
        case presenting(CGFloat), changing(CGFloat), dismissing
    }

    /// Add animatable changes to this closure
    /// They will be animated when the keyboard shows, changes height, or hides
    var animateAlongsideKeyboardChanges: ((Change) -> Void)?

    override init() {
        super.init()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.keyboardWillPresent(_:)), name: .UIKeyboardWillShow, object: nil)
        nc.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        nc.addObserver(self, selector: #selector(self.keyboardWillDismiss(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    private func animate(changes: Change, from notification: Notification) {
        guard
            let animationDuration = notification.keyboardAnimationDuration,
            let animationCurve = notification.keyboardAnimationCurve,
            animationDuration > 0 // don't animate if the duration is 0
        else {
            self.animateAlongsideKeyboardChanges?(changes)
            return
        }
        let options = UIViewAnimationOptions(rawValue: animationCurve)
        UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: {
            self.animateAlongsideKeyboardChanges?(changes)
        }, completion: nil)
    }

    @objc private func keyboardWillPresent(_ notification: Notification) {
        let keyboardHeight = notification.keyboardEndHeight ?? -1
        self.animate(changes: .presenting(keyboardHeight), from: notification)
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        let keyboardHeight = notification.keyboardEndHeight ?? -1
        self.animate(changes: .changing(keyboardHeight), from: notification)
    }

    @objc private func keyboardWillDismiss(_ notification: Notification) {
        self.animate(changes: .dismissing, from: notification)
    }

    deinit {
        // unsubscribing is no longer needed, but if this code gets used on older iOS this will stop crashes
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification {
    fileprivate var keyboardEndHeight: CGFloat? {
        return (self.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
    }
    fileprivate var keyboardAnimationDuration: TimeInterval? {
        return (self.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
    fileprivate var keyboardAnimationCurve: UInt? {
        return (self.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
    }
}
