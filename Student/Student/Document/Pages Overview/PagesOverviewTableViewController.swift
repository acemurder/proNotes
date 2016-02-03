//
//  PagesOverviewTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesOverviewTableViewController: UITableViewController, DocumentSynchronizerDelegate, ReordableTableViewDelegate {

    var shouldReload = true

    var document: Document? = DocumentSynchronizer.sharedInstance.document {
        didSet {
            if shouldReload {
                tableView.reloadData()
            } else {
                shouldReload = true
            }
        }
    }

    weak var pagesOverViewDelegate: PagesOverviewTableViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        (tableView as? ReordableTableView)?.reordableDelegate = self
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DocumentSynchronizer.sharedInstance.addDelegate(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(firstIndex: Int, secondIndex: Int) {
        // TODO
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PagesOverviewTableViewCell.identifier, forIndexPath: indexPath) as! PagesOverviewTableViewCell

        cell.numberLabel.text = String(indexPath.row + 1)
        cell.index = indexPath.row
        cell.delegate = pagesOverViewDelegate

        return cell
    }

    // MARK: - DocumentSynchronizerDelegate
    func updateDocument(document: Document, forceReload: Bool) {
        shouldReload = forceReload
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }
}
