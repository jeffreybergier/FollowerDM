//
//  ImageTitleSubtitleLabelTableViewCell.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

/// Using a really dumb cell class so that we can use it in more places
/// There are extensions that allow this cell to be configured with model objects
class ImageTitleSubtitleLabelTableViewCell: UITableViewCell {
    var uniqueIdentifier: String?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var primaryImageView: UIImageView?
}
