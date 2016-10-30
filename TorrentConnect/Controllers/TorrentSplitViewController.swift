//
//  TorrentSplitViewController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

protocol SelectBehaviourDelegate {
    func open(_ model: Torrent)
    func select(_ models: [Torrent])
    func deselect()
}

class TorrentSplitViewController: NSSplitViewController, SelectBehaviourDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupListController()
    }
    
    func detailsHided() -> Bool {
        return splitViewItems[1].animator().isCollapsed
    }
    
    func showDetails() {
        DispatchQueue.main.async {
            self.splitViewItems[1].animator().isCollapsed = false
        }
    }
    
    func hideDetails() {
        DispatchQueue.main.async {
            self.splitViewItems[1].animator().isCollapsed = true
        }
    }
    
    func setupListController() {
        let listController = splitViewItems[0].viewController as? TorrentsListViewController
        listController?.setupController(self)
    }
    
    func setupDetailsController(_ models: [Torrent]) {
        let detailsController = splitViewItems[1].viewController as? TorrentDetailsViewController
        detailsController?.selectBehaviour = self
        if (models.count == 1) {
            detailsController?.showOneTorrent(models[0])
        } else {
            detailsController?.showManyTorrents(models)
        }
    }
    
    func open(_ model: Torrent) {
        setupDetailsController([model])
        showDetails()
    }
    
    func select(_ models: [Torrent]) {
        if models.isEmpty {
            hideDetails()
            return
        }
        
        if models.count == 1 && detailsHided() {
            return
        }
        
        setupDetailsController(models)
        showDetails()
    }
    
    func deselect() {
        hideDetails()
        if let listController = splitViewItems[0].viewController as? TorrentsListViewController {
            listController.onDeselectTorrents()
        }
    }
}
