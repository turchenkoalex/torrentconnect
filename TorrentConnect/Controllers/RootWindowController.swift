//
//  RootWindowController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class RootWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titleVisibility = NSWindowTitleVisibility.hidden
        window?.titlebarAppearsTransparent = true
    }
}
