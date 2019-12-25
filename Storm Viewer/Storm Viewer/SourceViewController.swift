//
//  SourceViewController.swift
//  Storm Viewer
//
//  Created by Rakesh Kumar on 25/12/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa

class SourceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView: NSTableView!
    
    private var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        getListOfImages()
    }
    
    private func getListOfImages() {
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let items = try? fileManager.contentsOfDirectory(atPath: path) else {
            return
        }
        
        for item in items {
            if item.hasPrefix("nssl"){
                pictures.append(item)
            }
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pictures.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        vw.textField?.stringValue = pictures[row]
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard tableView.selectedRow != -1 else {
            return
        }
        
        guard let splitVC = parent as? NSSplitViewController else {
            return
        }
        
        if let detailVC = splitVC.children.last as? DetailViewController {
            detailVC.imageSelected(name: pictures[tableView.selectedRow])
        }
    }
}
