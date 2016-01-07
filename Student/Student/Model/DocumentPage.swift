//
//  DocumentPage.swift
//  Student
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentPage {
    var layers = [DocumentLayer]()
    var index = 0
    var size = UIScreen.mainScreen().bounds.size

    init(index: Int) {
        self.index = index
    }

    init(PDF: CGPDFPage, index: Int) {
        self.index = index
        addPDFLayer(PDF)
    }

    init(fileWrapper: NSFileWrapper, index: Int) {
        self.index = index
        if let contents = fileWrapper.fileWrappers {
            for wrapper in contents {
                if let innerWrappers = wrapper.1.fileWrappers {
                    var propertiesWrapper: NSFileWrapper?
                    var contentWrapper: NSFileWrapper?
                    for innerWrapper in innerWrappers {
                        if innerWrapper.0 == "properties" {
                            propertiesWrapper = innerWrapper.1
                        } else if innerWrapper.0 == "content" {
                            contentWrapper = innerWrapper.1
                        }
                    }
                    if propertiesWrapper != nil {
                        if let propertiesData = propertiesWrapper!.regularFileContents {
                            if let properties = NSKeyedUnarchiver.unarchiveObjectWithData(propertiesData) as? [String:AnyObject] {

                                switch DocumentLayerType(rawValue: properties["type"] as! Int)! {
                                case .Drawing:
                                    let layer = DocumentDrawLayer(docPage: self, properties: properties)
                                    if contentWrapper != nil {
                                        if let contentData = contentWrapper!.regularFileContents {
                                            layer.handleContentData(contentData)
                                        }
                                    }
                                    layers.append(layer)
                                    break
                                case .Image:
                                    let layer = ImageLayer(docPage: self, properties: properties)
                                    if contentWrapper != nil {
                                        if let contentData = contentWrapper!.regularFileContents {
                                            layer.handleContentData(contentData)
                                        }
                                    }
                                    layers.append(layer)
                                case .Text:
                                    let layer = TextLayer(docPage: self, properties: properties)
                                    layers.append(layer)
                                    break
                                case .Plot:
                                    let layer = PlotLayer(docPage: self, properties: properties)
                                    layers.append(layer)
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        updateLayerIndex()
    }

    func addDrawingLayer(image: UIImage?) -> DocumentDrawLayer {
        let drawLayer = DocumentDrawLayer(index: layers.count, image: image, docPage: self)
        layers.append(drawLayer)
        return drawLayer
    }

    func addPDFLayer(PDF: CGPDFPage) {
        let pdfLayer = DocumentPDFLayer(index: layers.count, page: PDF, docPage: self)
        layers.append(pdfLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func addImageLayer(image: UIImage) {
        let layerSize = image.sizeToFit(size)
        let imageLayer = ImageLayer(index: layers.count, docPage: self, origin: CGPointZero, size: layerSize, image: image)
        layers.append(imageLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func addTextLayer(text: String) -> TextLayer {
        let textLayer = TextLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 200, height: 200), text: "")
        layers.append(textLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        return textLayer
    }

    func addPlotLayer() {
        let plotLayer = PlotLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 500, height: 300))
        layers.append(plotLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func changeLayerVisibility(hidden: Bool, layer: DocumentLayer) {
        if layer.index < layers.count {
            layer.hidden = hidden
            layers[layer.index] = layer
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        }
    }

    func removeLayer(layer: DocumentLayer, forceReload: Bool) {
        if layer.index < layers.count {
            layers.removeAtIndex(layer.index)
            updateLayerIndex()
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: forceReload)
        }
    }

    func swapLayerPositions(firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < layers.count && secondIndex < layers.count {
            let tmp = firstIndex
            layers[firstIndex].index = secondIndex
            layers[secondIndex].index = tmp
            swap(&layers[firstIndex], &layers[secondIndex])
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        }
    }

    func updateLayerIndex() {
        for (index, currentLayer) in layers.enumerate() {
            currentLayer.index = index
        }
    }

    func getFileWrapper() -> NSFileWrapper {
        var fileWrappers: [String:NSFileWrapper] = [String: NSFileWrapper]()

        for layer in layers {
            fileWrappers[String(layer.index)] = layer.getFileWrapper()
        }
        let contents = NSFileWrapper(directoryWithFileWrappers: fileWrappers)
        return contents
    }

}
