//
//  MovableTextView.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView, UITextViewDelegate, TextSettingsDelegate {

    var text = ""
    var textView = UITextView()

    init(text: String, frame: CGRect, movableLayer: MovableLayer) {
        self.text = text
        super.init(frame: frame, movableLayer: movableLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUpTextView() {
        clipsToBounds = true

        textView.text = text
        textView.userInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clearColor()
        textView.delegate = self

        addSubview(textView)
        addAutoLayoutConstraints(textView)
    }

    override func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        textView.becomeFirstResponder()
    }

    override func setUpSettingsViewController() {
        TextSettingsViewController.delegate = self
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Text
    }

    override func setDeselected() {
        textView.resignFirstResponder()
    }

    // MARK: - TextSettingsDelegate 

    func changeTextColor(color: UIColor) {
        textView.textColor = color
    }

    func changeBackgroundColor(color: UIColor) {
        textView.backgroundColor = color
    }

    func changeAlignment(textAlignment: NSTextAlignment) {
        textView.textAlignment = textAlignment
    }

    func changeFont(font: UIFont) {
        textView.font = font
    }

    func disableAutoCorrect(disable: Bool) {
        if disable {
            textView.autocorrectionType = .No
        } else {
            textView.autocorrectionType = .Yes
        }
    }

    func removeText() {
        textView.text = ""
    }

    override func saveChanges() {
        if let textLayer = movableLayer as? TextLayer {
            textLayer.text = textView.text
        }
        super.saveChanges()
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        let heightOffset = textView.contentSize.height - textView.bounds.size.height
        if heightOffset > 0 {
            let origin = frame.origin
            var size = bounds.size
            size.height += heightOffset
            frame = CGRect(origin: origin, size: size)
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        saveChanges()
    }

}
