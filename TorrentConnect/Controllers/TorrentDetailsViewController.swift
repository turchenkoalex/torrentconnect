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
    var oneTorrentController: OneTorrentDetailController?
    var manyTorrentsController: ManyTorrentsDetailController?
    var injectedType: Int = 0
    
    func getManyTorrentsController() -> ManyTorrentsDetailController {
        if (manyTorrentsController != nil) {
            return manyTorrentsController!
        }
        
        manyTorrentsController = self.storyboard?.instantiateControllerWithIdentifier("manyTorrents") as? ManyTorrentsDetailController
        manyTorrentsController?.view.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        manyTorrentsController?.hide = self.hide
        return manyTorrentsController!
    }
    
    func getOneTorrentController() -> OneTorrentDetailController {
        if (oneTorrentController != nil) {
            return oneTorrentController!
        }
        
        oneTorrentController = self.storyboard?.instantiateControllerWithIdentifier("oneTorrent") as? OneTorrentDetailController
        oneTorrentController?.view.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
        oneTorrentController?.hide = self.hide
        return oneTorrentController!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true
    }
    
    func showOneTorrent(torrent: Torrent) {
        let ctrl = getOneTorrentController()
        ctrl.setupModel(torrent)
        injectController(ctrl, type: 1)
    }
    
    func showManyTorrents(torrents: [Torrent]) {
        let ctrl = getManyTorrentsController()
        ctrl.setupModel(torrents)
        injectController(ctrl, type: 2)
    }
    
    func injectController(controller: NSViewController, type: Int) {
        if (type == injectedType) {
            return
        }
        
        injectedType = type
        self.insertChildViewController(controller, atIndex: 0)
        if (self.view.subviews.count > 1) {
            self.view.subviews.removeAtIndex(1)
        }
        
        self.view.frame = controller.view.frame
        self.view.addSubview(controller.view)

        if (self.childViewControllers.count > 1) {
            self.removeChildViewControllerAtIndex(1)
        }
    }
    
    func hide() {
        self.selectBehaviour?.deselect()
    }
    
    @IBAction func closeDetails(sender: AnyObject) {
        self.selectBehaviour?.deselect()
    }
}
