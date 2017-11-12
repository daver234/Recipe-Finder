//
//  NoNetworkView.swift
//  BlueCart
//
//  Created by David Rothschild on 11/12/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import UIKit

/// View to display message when no network connectivity
class TableViewHelper {
    
    class func EmptyMessage(message: String, viewController: UIViewController, tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: Constants.AVENIR, size: 18)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
}
