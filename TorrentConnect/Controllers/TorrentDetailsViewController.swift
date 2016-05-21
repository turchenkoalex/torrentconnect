//
//  TorrentDetailsViewController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentDetailsViewController: NSViewController {
    var selectBehaviour: SelectBehaviourDelegate?
    var oneTorrentController: OneTorrentDetailController!
    var manyTorrentsController: ManyTorrentsDetailController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true
    }
    
    func showOneTorrent(torrent: TorrentModel) {
        let ctrl = makeController("oneTorrent") as! OneTorrentDetailController
        ctrl.hide = self.hide
        ctrl.setupModel(torrent)
    }
    
    func showManyTorrents(torrents: [TorrentModel]) {
        let ctrl = makeController("manyTorrents") as! ManyTorrentsDetailController
        ctrl.hide = self.hide
        ctrl.setupModel(torrents)
    }
    
    func makeController(identifier: String) -> NSViewController {
        let controller = self.storyboard?.instantiateControllerWithIdentifier(identifier) as! NSViewController
        
        self.insertChildViewController(controller, atIndex: 0)
        
        if (self.view.subviews.count > 1) {
            self.view.replaceSubview(self.view.subviews[1], with: controller.view)
        } else {
            self.view.addSubview(controller.view)
        }
        
        if (self.childViewControllers.count > 1) {
            self.removeChildViewControllerAtIndex(1)
        }
        
        self.view.frame = controller.view.frame
        
        controller.view.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        
        return controller
    }
    
    func hide() {
        self.selectBehaviour?.deselect()
    }
    
    @IBAction func closeDetails(sender: AnyObject) {
        self.selectBehaviour?.deselect()
    }
}
