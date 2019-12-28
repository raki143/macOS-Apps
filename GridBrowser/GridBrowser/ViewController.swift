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
    private var selectedWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        
        // enable the customize Touch Bar Menu Item
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        // create a Touch Bar with a unique identifier, making 'viewcontroller' its delegate
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.rakesh.GridBrowser")
        touchBar.delegate = self
        
        // set up some meaningful defaults
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .sharingPicker]
        
        // make the address entry button it in the centre of the bar
        touchBar.principalItemIdentifier = .enterAddress
        
        // allow the user to customize these four controls
        touchBar.customizationAllowedItemIdentifiers = [.sharingPicker, .adjustGrid, .adjustRows, .adjustColumns]
        
        // but don't let them take off the url entry button
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]
        
        return touchBar
    }
    
    private func makeWebView() -> NSView {
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked(recognizer:)))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
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
        
        guard  let selected = selectedWebView else {
            return
        }
        
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        guard let selectedWebView = selectedWebView else {
            return
        }
        
        if sender.selectedSegment == 0 {
            // back was tapped
            selectedWebView.goBack()
        }else {
            // forward was tapped
            selectedWebView.goForward()
        }
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
    
    private func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc private func webViewClicked(recognizer: NSClickGestureRecognizer) {
        
        // get the webview that triggered this method
        guard let newSelectedWebView = recognizer.view as? WKWebView else {
            return
        }
        
        // deselect the currently selected webview if there is one
        if let currentWebView = selectedWebView {
            currentWebView.layer?.borderWidth = 0
        }
        
        // select the new webview.
        select(webView: newSelectedWebView)
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        guard webView == selectedWebView else {
            return
        }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
}

extension ViewController: NSGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        
        if gestureRecognizer.view == selectedWebView {
            return false
        }else {
            return true
        }
    }
}

extension NSTouchBarItem.Identifier {
    static let navigation = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.navigation")
    static let enterAddress = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.enterAddress")
    static let sharingPicker = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.sharingPicker")
    static let adjustGrid = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.adjustGrid")
    static let adjustRows = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.adjustRows")
    static let adjustColumns = NSTouchBarItem.Identifier(rawValue: "com.rakesh.GridBrowser.adjustColumns")
}

extension ViewController: NSTouchBarDelegate {

   // @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        
        case NSTouchBarItem.Identifier.enterAddress:
            let button = NSButton(title: "Enter a URL", target: self, action: #selector(selectAddressEntry))
            button.setContentHuggingPriority(NSLayoutConstraint.Priority(10), for: .horizontal)
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = button
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.navigation:
            // load back and forth images
            let back = NSImage(named: NSImage.touchBarGoBackTemplateName)!
            let forward = NSImage(named: NSImage.touchBarGoForwardTemplateName)!
            
            // create a segment control out of them, calling our navigationClicked() method.
            let segmentedControl = NSSegmentedControl(images: [back,forward], trackingMode: .momentary, target: self, action: #selector(navigationClicked(_:)))
            
            // wrap that inside touchbar item
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = segmentedControl
            
            // send it back
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.sharingPicker:
            
            let picker = NSSharingServicePickerTouchBarItem(identifier: identifier)
            picker.delegate = self
            return picker
           
        case NSTouchBarItem.Identifier.adjustRows:
            let control = NSSegmentedControl(labels: ["Add Rows", "Remove Row"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustRows(_:)))
            
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Rows"
            customTouchBarItem.view = control
            
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.adjustColumns:
            let control = NSSegmentedControl(labels: ["Add Cols", "Remove Cols"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustColumns(_:)))
            
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Columns"
            customTouchBarItem.view = control
            
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.adjustGrid:
            let popover = NSPopoverTouchBarItem(identifier: identifier)
            popover.collapsedRepresentationLabel = "Grid"
            popover.customizationLabel = "Adjust Grid"
            popover.popoverTouchBar = NSTouchBar()
            popover.popoverTouchBar.delegate = self
            popover.popoverTouchBar.defaultItemIdentifiers = [.adjustRows, .adjustColumns]
            return popover
            
        default:
            return nil
        }
    }
    
    @objc private func selectAddressEntry() {
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry)
        }
    }
   
}

extension ViewController: NSSharingServicePickerTouchBarItemDelegate {
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        guard let webView = selectedWebView else {
            return []
        }
        guard let url = webView.url?.absoluteString else {
            return []
        }
        
        return [url]
    }
}
