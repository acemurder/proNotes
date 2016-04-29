//
//  DocumentExporter.swift
//  Student
//
//  Created by Leo Thomas on 10/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentExporter: NSObject {

    class func exportAsImages(progress: (Float) -> Void) -> [UIImage]{
        guard let document = DocumentInstance.sharedInstance.document else {
            return []
        }
        let images = getImageArrayForDocument(document, progress: progress)
        return images
    }

    class func exportAsPDF(progress: (Float) -> Void) -> NSData? {
            guard let document = DocumentInstance.sharedInstance.document else {
                return nil
            }
            let mutableData = NSMutableData()
            let rect = CGRect(origin: CGPoint.zero, size: document.pages.first!.size)
            UIGraphicsBeginPDFContextToData(mutableData, rect, nil)
            let context = UIGraphicsGetCurrentContext()
            for image in getImageArrayForDocument(document, progress: progress) {
                let imageRect = CGRect(origin: CGPoint.zero, size: image.size)
                UIGraphicsBeginPDFPageWithInfo(imageRect, nil)
                CGContextDrawImage(context, imageRect, image.CGImage!)
            }
            UIGraphicsEndPDFContext()
            return mutableData
    }

    class func exportAsProNote(progress: (Float) -> Void, url: (NSURL?) -> Void) {
        progress(0.5)
        DocumentInstance.sharedInstance.save({ (_) in
        progress(1)
            guard let document = DocumentInstance.sharedInstance.document else {
                url(nil)
                return
            }
            url(document.fileURL)
        })
        
    }
    
    class func getImageArrayForDocument(document: Document, progress: (Float) -> Void) -> [UIImage] {
        var images = [UIImage]()
        for (index, page) in document.pages.enumerate() {
            let pageView = PageView(page: page, renderMode: true)
            pageView.layoutIfNeeded()
            images.append(pageView.toImage())
            progress(Float(index+1)/Float(document.pages.count))
        }
        return images
    }
    
    class func presentActivityViewController(viewController: UIViewController, sourceView: UIView?, barbuttonItem: UIBarButtonItem?, items: [AnyObject] ) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.barButtonItem = barbuttonItem
        viewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
