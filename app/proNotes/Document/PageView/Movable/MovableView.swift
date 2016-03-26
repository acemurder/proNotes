//
//  MovableView.swift
//  proNotes
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableView: TouchControlView, PageSubView {

    // TODO style

    var movableLayer: MovableLayer!
    var debugMode = true
    
    private var renderMode = false

    init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        self.movableLayer = movableLayer
        let newControlLength: CGFloat = 44

        super.init(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.size.width + newControlLength * 2, height: frame.size.height + newControlLength * 2)))
        controlLength = newControlLength
        self.renderMode = renderMode
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didAddSubview(subview: UIView) {
        if !renderMode {
            subview.translatesAutoresizingMaskIntoConstraints = false
            let leftConstraint = NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: controlLength)
            let rightConstraint = NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -controlLength)
            let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -controlLength)
            let topConstraint = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: controlLength)
            
            addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
            layoutIfNeeded()
        } else {
            clipsToBounds = false
            subview.frame = CGRect(origin: CGPoint(x: controlLength, y: controlLength), size: CGSize(width: movableLayer.size.width, height: movableLayer.size.height))
        }
    }

    func setSelected() {
        handleTap(nil)
    }
    
    // MARK: - Gesture Recognizer

    func handleTap(recognizer: UITapGestureRecognizer?) {
        isEditing = !isEditing

        if isEditing {
            setUpSettingsViewController()
        } else {
            setDeselected()
            SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
        }

        setNeedsDisplay()
    }
    

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        frame = super.handlePanTranslation(translation)
        layoutIfNeeded()
        setNeedsDisplay()
        return frame
    }

    func updateFrameChanges() {
        movableLayer.origin = frame.origin
        if movableLayer.docPage != nil && oldFrame != nil {
            DocumentInstance.sharedInstance.registerUndoAction(NSValue(CGRect: oldFrame!), pageIndex: movableLayer.docPage.index, layerIndex: movableLayer.index)
        }

        var newSize = frame.size
        movableLayer.size = newSize.increaseSize(controlLength * (-2))
        saveChanges()
    }

    override func handlePanEnded() {
        super.handlePanEnded()
        updateFrameChanges()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if isEditing {
            let context = UIGraphicsGetCurrentContext()
            if debugMode {
                for touchRect in getControlRects().values {
                    UIColor.randomColor().colorWithAlphaComponent(0.5).setFill()
                    CGContextFillRect(context, touchRect)
                }
            }
        }
    }

    func saveChanges() {
        let pageIndex = movableLayer.docPage.index
        DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
    }

    func setUpSettingsViewController() {
        // empty Base implementation
    }

    func setDeselected() {
        // empty Base implementation
    }

    func undoAction(oldObject: AnyObject?) {
        guard let value = oldObject as? NSValue else {
            return
        }
        let frame = value.CGRectValue()
        oldFrame = self.frame
        UIView.animateWithDuration(standardAnimationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.frame = frame
        }, completion: nil)
        updateFrameChanges()
    }
    
}
