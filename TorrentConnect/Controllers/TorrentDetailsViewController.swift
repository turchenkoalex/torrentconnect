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
        
        manyTorrentsController = self.storyboard?.instantiateController(withIdentifier: "manyTorrents") as? ManyTorrentsDetailController
        manyTorrentsController?.view.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        manyTorrentsController?.hide = self.hide
        return manyTorrentsController!
    }
    
    func getOneTorrentController() -> OneTorrentDetailController {
        if (oneTorrentController != nil) {
            return oneTorrentController!
        }
        
        oneTorrentController = self.storyboard?.instantiateController(withIdentifier: "oneTorrent") as? OneTorrentDetailController
        oneTorrentController?.view.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        oneTorrentController?.hide = self.hide
        return oneTorrentController!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true
    }
    
    func showOneTorrent(_ torrent: Torrent) {
        let ctrl = getOneTorrentController()
        ctrl.setupModel(torrent)
        injectController(ctrl, type: 1)
    }
    
    func showManyTorrents(_ torrents: [Torrent]) {
        let ctrl = getManyTorrentsController()
        ctrl.setupModel(torrents)
        injectController(ctrl, type: 2)
    }
    
    func injectController(_ controller: NSViewController, type: Int) {
        if (type == injectedType) {
            return
        }
        
        injectedType = type
        self.insertChildViewController(controller, at: 0)
        if (self.view.subviews.count > 1) {
            self.view.subviews.remove(at: 1)
        }
        
        self.view.frame = controller.view.frame
        self.view.addSubview(controller.view)

        if (self.childViewControllers.count > 1) {
            self.removeChildViewController(at: 1)
        }
    }
    
    func hide() {
        self.selectBehaviour?.deselect()
    }
    
    @IBAction func closeDetails(_ sender: AnyObject) {
        self.selectBehaviour?.deselect()
    }
}
