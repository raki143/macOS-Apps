//
//  ViewController.swift
//  GridBrowser
//
//  Created by Rakesh Kumar on 25/12/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    private var rowsStackView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        return webView
    }
    
    private func setup() {
        
        // 1. create the stack view and add it to our view
        rowsStackView = NSStackView()
        rowsStackView.orientation = .vertical
        rowsStackView.distribution = .fillEqually
        rowsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rowsStackView)
        
        // 2. create Auto Layout onstraints that pin the stackview to the edges of its container
        rowsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rowsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rowsStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rowsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // 3. create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        // 4. Add this column to the rows stackview.
        rowsStackView.addArrangedSubview(column)
    }

    @IBAction func urlEntered(_ sender: NSTextField) {
        print("urlEntered")
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        print("navigationClicked")
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // add new row of webviews
            addWebViewRows()
        }else {
            // remove last row of webviews
            deleteLastWebViewRows()
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
       
        if sender.selectedSegment == 0 {
            // we need to add a cloumn
            addWebViewsInNewColumn()
        }else {
            // we need to delete a column
            removeWebViewsInLastColumn()
        }
    }
    
    private func addWebViewsInNewColumn() {
        for case let row as NSStackView in rowsStackView.arrangedSubviews {
            // loop over each row and add a new webview to it.
            row.addArrangedSubview(makeWebView())
        }
    }
    
    private func removeWebViewsInLastColumn() {
        // pull out the first of our rows
        guard let firstRow = rowsStackView.arrangedSubviews.first as? NSStackView else {
            return
        }
        
        // make sure it has atleast two columns
        guard firstRow.arrangedSubviews.count > 1 else {
            return
        }
        
        // if we are still here it means it's safe to delete a column
        for case let row as NSStackView in rowsStackView.arrangedSubviews {
            
            // loop over every row
            if let last = row.arrangedSubviews.last {
                
                // pull out the last web view in this column and remove it using the two step process
                row.removeArrangedSubview(last)
                last.removeFromSuperview()
            }
        }
    }
    
    private func addWebViewRows() {
        
        // count how many columns we have so far
        let columnCount = (rowsStackView.arrangedSubviews.first as! NSStackView).arrangedSubviews.count
        
        // make a new array of web Views that contain the correct number of columns
        let viewArray = (0 ..< columnCount).map{ _ in makeWebView() }
        
        // use that webView to create a new stack view
        let row = NSStackView(views: viewArray)
        
        // make that stackview size its children equally, then add it to our rows array
        row.distribution = .fillEqually
        rowsStackView.addArrangedSubview(row)
    }
    
    private func deleteLastWebViewRows() {
        
        // make sure we have atleast two rows
        guard rowsStackView.arrangedSubviews.count > 1 else {
            return
        }
        
        // pull out the final row, make sure its a stackview
        guard let rowToRemove = rowsStackView.arrangedSubviews.last as? NSStackView else {
            return
        }
        
        // loop through each web view in the row, removing it from the screen
        for cell in rowToRemove.arrangedSubviews {
            cell.removeFromSuperview()
        }
        // finally remove the whole stackview row
        rowsStackView.removeArrangedSubview(rowToRemove)
    }
}

extension ViewController: WKNavigationDelegate {
    
}
