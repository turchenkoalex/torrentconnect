//
//  TorrentSplitViewController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

protocol TorrentSelectedProtocol {
    func select(model: TorrentModel)
    func select(models: [TorrentModel])
    func close()
}

class TorrentSplitViewController: NSSplitViewController, TorrentSelectedProtocol {

    private var _torrentsListController: TorrentsListViewController?
    private var _torrentDetailsController: TorrentDetailsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        _torrentsListController = splitViewItems[0].viewController as? TorrentsListViewController
        _torrentDetailsController = splitViewItems[1].viewController as? TorrentDetailsViewController

        _torrentsListController?.setupController(self)
        _torrentDetailsController?.torrentSelectedDelegate = self
    }
    
    func select(model: TorrentModel) {
        _torrentDetailsController?.setupController(model)
        splitViewItems[1].animator().collapsed = false
    }
    
    func select(models: [TorrentModel]) {
        _torrentDetailsController?.setupController(models)
        splitViewItems[1].animator().collapsed = false
    }
    
    func close() {
        splitViewItems[1].animator().collapsed = true
    }
}
