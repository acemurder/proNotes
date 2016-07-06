//
//  PageSubView.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@objc
protocol PageSubView: class {

    optional func saveChanges()

    optional func handlePan(panGestureRecognizer: UIPanGestureRecognizer)

    optional func setSelected()

    optional func setDeselected()

    optional func setUpSettingsViewController()

    optional func undoAction(oldObject: AnyObject?)

}
