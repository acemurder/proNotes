//
//  PageView.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageView: UIView {
    
    var pdfViewDelegate: PDFViewDelegate?
    var page : DocumentPage? {
        didSet{
            setUpLayer()
        }
    }
    
    func setUpLayer() {
        
        for view in subviews {
            view.removeFromSuperview()
        }
        
        for layer in page!.layer {
            switch layer.type {
            case .PDF:
                addPDFView(layer as! DocumentPDFLayer)
                break
            case .Drawing:
                addDrawingView(layer as! DocumentDrawLayer)
                break
            case .Image:
                addImageLayer(layer as! ImageLayer)
                break
            case .Text:
                addTextLayer(layer as! TextLayer)
                break
            }
        }
        setNeedsDisplay()
    }
    
    func addPDFView(layer: DocumentPDFLayer) {
        let view = PDFView(page: layer.page, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.delegate = pdfViewDelegate
        addSubview(view)
    }
    
    func addDrawingView(drawLayer: DocumentDrawLayer) {
        let view = DrawingView(drawLayer: drawLayer, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        addSubview(view)
    }
    
    func addImageLayer(imageLayer :ImageLayer){
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(image: imageLayer.image, frame: frame, movableLayer: imageLayer)
        addSubview(view)
        view.setUpImageView()
    }
    
    func addTextLayer(textLayer: TextLayer) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(text: textLayer.text, frame: frame, movableLayer: textLayer)
        addSubview(view)
        view.setUpTextView()
    }
    
    func getDrawingViews() -> [DrawingView]{
        var result = [DrawingView]()
        for view in subviews {
            if let drawingView = view as? DrawingView {
                result.append(drawingView)
            }
        }
        return result
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}