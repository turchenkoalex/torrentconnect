//
//  TorrentSplitViewController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

protocol SelectBehaviourDelegate {
    func open(model: TorrentModel)
    func select(models: [TorrentModel])
    func deselect()
}

class TorrentSplitViewController: NSSplitViewController, SelectBehaviourDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupListController()
    }
    
    func detailsHided() -> Bool {
        return splitViewItems[1].animator().collapsed
    }
    
    func showDetails() {
        splitViewItems[1].animator().collapsed = false
    }
    
    func hideDetails() {
        splitViewItems[1].animator().collapsed = true
    }
    
    func setupListController() {
        let listController = splitViewItems[0].viewController as? TorrentsListViewController
        listController?.setupController(self)
    }
    
    func setupDetailsController(models: [TorrentModel]) {
        let detailsController = splitViewItems[1].viewController as? TorrentDetailsViewController
        detailsController?.selectBehaviour = self
        if (models.count == 1) {
            detailsController?.setupController(models[0])
        } else {
            detailsController?.setupController(models)
        }
    }
    
    func open(model: TorrentModel) {
        setupDetailsController([model])
        showDetails()
    }
    
    func select(models: [TorrentModel]) {
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
    }
}
