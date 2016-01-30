//
//  DrawingView.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DrawingView: UIImageView, PageSubView, DrawingSettingsDelegate {

    var strokeColor = UIColor.blackColor()
    var lineWidth: CGFloat = 2
    var drawingType: DrawingType = .Pen

    var markerAlphaValue = 0.5
    var markerLineWidth: CGFloat = 4
    var penLineWidth: CGFloat = 2
    var eraserLineWidth: CGFloat = 15

    var path = UIBezierPath()
    var incrementalImage: UIImage?
    var points = [CGPoint?](count: 5, repeatedValue: nil)

    var didChange = false

    var counter = 0
    var drawLayer: DocumentDrawLayer? {
        didSet {
            incrementalImage = drawLayer?.image
        }
    }

    init(drawLayer: DocumentDrawLayer, frame: CGRect) {
        self.drawLayer = drawLayer
        incrementalImage = self.drawLayer?.image
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        saveChanges()
    }

    func commonInit() {
        multipleTouchEnabled = false
        backgroundColor = UIColor.clearColor()
        path.lineWidth = 2.0
    }

    override func drawRect(rect: CGRect) {
        if incrementalImage != nil {
            incrementalImage!.drawInRect(rect)
        }
        stroke()
    }

    override func saveChanges() {
        if incrementalImage != nil && drawLayer != nil && didChange {
            drawLayer?.image = incrementalImage
            DocumentSynchronizer.sharedInstance.updateDrawLayer(drawLayer!, forceReload: false)
            didChange = false
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        points[0] = (touch?.locationInView(self))!
    }


    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point = touch?.locationInView(self)
        counter++
        points[counter] = point!
        if counter == 4 {
            points[3] = CGPointMake((points[2]!.x + points[4]!.x) / 2.0, (points[2]!.y + points[4]!.y) / 2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            path.moveToPoint(points[0]!)
            path.addCurveToPoint(points[3]!, controlPoint1: points[1]!, controlPoint2: points[2]!)
            setNeedsDisplay()


            // replace points and get ready to handle the next segment
            points[0] = points[3];
            points[1] = points[4];
            counter = 1;
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesEnd()
    }

    func touchesEnd() {
        didChange = true
        drawBitmap()
        setNeedsDisplay()
        path.removeAllPoints()
        counter = 0
        saveChanges()
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnd()
    }

    func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);

//        if incrementalImage == nil {
//            let rectPath = UIBezierPath(rect: self.bounds)
//            backgroundColor?.setFill()
//            rectPath.fill()
//        }
        incrementalImage?.drawInRect(bounds)
        stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    func stroke() {
        setUpStrokeColor()
        setUpLineWidth()
        if drawingType == .Eraser {
            path.strokeWithBlendMode(.Clear, alpha: 1.0)
        } else {
            path.stroke()
        }
    }

    override func setSelected() {
        SettingsViewController.sharedInstance?.currentSettingsType = .Drawing
        DrawingSettingsViewController.delegate = self
    }

    // MARK: - DrawingSettingsDelegate

    func clearDrawing() {
        self.incrementalImage = nil
        self.touchesEnd()
    }

    func removeLayer() {
        drawLayer?.removeFromPage()
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    func didSelectColor(color: UIColor) {
        strokeColor = color
        setUpStrokeColor()
    }

    func setUpStrokeColor() {
        if drawingType == .Marker {
            strokeColor.colorWithAlphaComponent(0.5).setStroke()
        } else {
            strokeColor.setStroke()
        }
    }

    func setUpLineWidth() {
        path.lineWidth = lineWidth
    }

    func didSelectDrawingType(type: DrawingType) {
        switch type {
        case .Pen:
            setUpPen()
            break
        case .Marker:
            setUpMarker()
            break
        case .Eraser:
            setUpEraser()
            break
        }
        drawingType = type
    }

    func didChangeLineWidth(lineWidth: CGFloat) {
        self.lineWidth = lineWidth
    }

    func setUpPen() {
        lineWidth = penLineWidth
    }

    func setUpMarker() {
        lineWidth = markerLineWidth
    }

    func setUpEraser() {
        lineWidth = eraserLineWidth
    }
}
