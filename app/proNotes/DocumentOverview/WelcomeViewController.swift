//
//  WelcomeViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var backLeftXConstraint: NSLayoutConstraint!
    @IBOutlet weak var backRightXConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleLeftXConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleRightXConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var notifyButton: UIButton!
    
    static weak var sharedInstance: WelcomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for case let imageView as UIImageView in view.subviews {
            imageView.layer.setUpDefaultShaddow()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Preferences.setIsFirstRun(false)
        animateImageViews()
        if Preferences.AlreadyDownloadedDefaultNote() {
            alredyDownloaded = true
        }
        WelcomeViewController.sharedInstance = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WelcomeViewController.sharedInstance = nil
    }
    
    func animateImageViews() {
        view.layoutIfNeeded()
        let middleOffSet: CGFloat = topImageView.bounds.width/3.8
        middleLeftXConstraint.constant = -middleOffSet
        middleRightXConstraint.constant = middleOffSet
        let backOffset: CGFloat = topImageView.bounds.width/2.1
        backLeftXConstraint.constant = -backOffset
        backRightXConstraint.constant = backOffset
        UIView.animate(withDuration: 1, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    @IBAction func handleContinueButtonPressed(_ sender: AnyObject) {
        Preferences.setShoudlShowWelcomeScreen(false)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func handleNotifyButtonPressed(_ sender: UIButton) {
        if alredyDownloaded {
        
        } else {
            sender.isHidden = true
            hintLabel.isHidden = true
            Preferences.setAllowsNotification(true)
            UIApplication.shared().registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
    }
    
    var alredyDownloaded: Bool = false {
        didSet {
            DispatchQueue.main.async(execute: {
                if self.alredyDownloaded {
                    self.notifyButton.isHidden = true
                    let attributedString = NSMutableAttributedString(string: "A sample Note has will be been downloaded via CloudKit")
                    
                    attributedString.addAttributes([NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)], range: NSRange(location: 18, length: 7))
                    UIView.transition(with: self.hintLabel, duration: standardAnimationDuration, options: [.transitionCrossDissolve], animations: {
                        self.hintLabel.attributedText = attributedString
                        }, completion: nil)
                    
                    
                }
                self.notifyButton.isUserInteractionEnabled = !self.alredyDownloaded
            })
        }
    }
}
