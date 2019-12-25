//
//  WindowController.swift
//  Storm Viewer
//
//  Created by Rakesh Kumar on 25/12/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var shareButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        shareButton.sendAction(on: .leftMouseDown)
    }
    
    @IBAction func sharedClicked(_ sender: NSView) {
        
        guard let splitVC = contentViewController as? ViewController else { return}
        guard let detailVC = splitVC.children.last as? DetailViewController else { return }
        guard let image = detailVC.imageView.image else { return }
        
        let picker = NSSharingServicePicker(items: [image])
        picker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }

}
