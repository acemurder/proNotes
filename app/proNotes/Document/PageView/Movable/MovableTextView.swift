//
//  MovableTextView.swift
//  proNotes
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView, UITextViewDelegate, TextSettingsDelegate {
    
    weak var textView: UITextView?
    
    var textLayer: TextLayer? {
        return movableLayer as? TextLayer
    }

    override init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        super.init(frame: frame, movableLayer: movableLayer, renderMode: renderMode)
        widthResizingOnly = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        widthResizingOnly = true
    }

    func setUpTextView() {
        clipsToBounds = true
        if self.textView == nil {
            let textView = UITextView()
            textView.userInteractionEnabled = false
            textView.backgroundColor = UIColor.clearColor()
            textView.delegate = self

            addSubview(textView)

            self.textView = textView
        }
        
        textView?.backgroundColor = textLayer?.backgroundColor
        textView?.textColor = textLayer?.textColor
        textView?.text = textLayer?.text
        textView?.font = textLayer?.font
        textView?.textAlignment = textLayer?.alignment ?? .Left
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        let rect = super.handlePanTranslation(translation)
        updateTextView()
        return rect
    }

    func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        textView?.becomeFirstResponder()
    }

    override func setUpSettingsViewController() {
        TextSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentSettingsType = .Text
    }

    override func setDeselected() {
        textView?.resignFirstResponder()
    }

    // MARK: - TextSettingsDelegate 

    func changeTextColor(color: UIColor) {
        textLayer?.textColor = color
        textView?.textColor = color
        saveChanges()
    }

    func changeBackgroundColor(color: UIColor) {
        textLayer?.backgroundColor = color
        textView?.backgroundColor = color
        saveChanges()
    }

    func changeAlignment(textAlignment: NSTextAlignment) {
        textLayer?.alignment = textAlignment
        textView?.textAlignment = textAlignment
        saveChanges()
    }

    func changeFont(font: UIFont) {
        textLayer?.font = font
        textView?.font = font
        saveChanges()
    }

    func removeText() {
        textView?.text = ""
    }
    
    func getTextLayer() -> TextLayer? {
        return textLayer
    }

    override func undoAction(oldObject: AnyObject?) {
        guard let text = oldObject as? String else {
            super.undoAction(oldObject)
            return
        }
        textView?.text = text
        updateText(text)
    }

    func updateText(newText: String) {
        if let textLayer = movableLayer as? TextLayer {
            if textLayer.docPage != nil {
                DocumentInstance.sharedInstance.registerUndoAction(textLayer.text, pageIndex: textLayer.docPage.index, layerIndex: textLayer.index)
            }
            textLayer.text = textView?.text ?? textLayer.text
            saveChanges()
        }

    }

    override func saveChanges() {
        super.saveChanges()
    }

    func updateTextView() {
        guard textView != nil else {
            return
        }
        let heightOffset = textView!.contentSize.height - textView!.bounds.size.height
        if heightOffset > 0 {
            let origin = frame.origin
            var size = bounds.size
            size.height += heightOffset
            frame = CGRect(origin: origin, size: size)
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        updateTextView()
    }

    func textViewDidEndEditing(textView: UITextView) {
        updateText(textView.text)
    }

}
