//
//  CrossfadeStoryboardSegue.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 21.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Cocoa

class CrossfadeStoryboardSegue: NSStoryboardSegue {
    override func perform() {
        // build from-to and parent-child view controller relationships
        let sourceViewController  = self.sourceController as! NSViewController
        let destinationViewController = self.destinationController as! NSViewController
        let containerViewController = sourceViewController.parent! as NSViewController
        
        // add destinationViewController as child
        containerViewController.insertChildViewController(destinationViewController, at: 1)
        
        // get the size of destinationViewController
        let targetSize = destinationViewController.view.frame.size
        let targetWidth = destinationViewController.view.frame.size.width
        let targetHeight = destinationViewController.view.frame.size.height
        
        // prepare for animation
        sourceViewController.view.wantsLayer = true
        destinationViewController.view.wantsLayer = true
        
        //perform transition
        containerViewController.transition(from: sourceViewController, to: destinationViewController, options: NSViewControllerTransitionOptions(), completionHandler: nil)
        
        //resize view controllers
        sourceViewController.view.animator().setFrameSize(targetSize)
        destinationViewController.view.animator().setFrameSize(targetSize)
        
        //resize and shift window
        let currentFrame = containerViewController.view.window?.frame
        let currentRect = NSRectToCGRect(currentFrame!)
        let horizontalChange = (targetWidth - containerViewController.view.frame.size.width)/2
        let verticalChange = (targetHeight - containerViewController.view.frame.size.height)/2
        let newWindowRect = NSMakeRect(currentRect.origin.x - horizontalChange, currentRect.origin.y - verticalChange, targetWidth, targetHeight)
        containerViewController.view.window?.setFrame(newWindowRect, display: true, animate: true)
        
        // lose the sourceViewController, it's no longer visible
        containerViewController.removeChildViewController(at: 0)
    }
}
