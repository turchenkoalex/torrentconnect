//
//  TorrentDetailsViewController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentDetailsViewController: NSViewController {

    @IBOutlet weak var labelField: NSTextField!
    @IBOutlet weak var manyTorrentsImage: NSImageView!
    
    private var _model: TorrentModel?
    var selectBehaviour: SelectBehaviourDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if _model != nil {
            setupController(_model!)
        }
    }
    
    func setupController(model: TorrentModel) {
        self._model = model
        
        labelField?.stringValue = model.name
        labelField?.hidden = false
        manyTorrentsImage?.hidden = true
    }
    
    func setupController(models: [TorrentModel]) {
        self._model = nil
        
        labelField?.hidden = true
        manyTorrentsImage?.hidden = false
    }
    
    @IBAction func closeClick(sender: AnyObject) {
        self.selectBehaviour?.deselect()
    }
    
    @IBAction func deleteTorrent(sender: AnyObject) {
        if let model = _model {
            TransmissionConnectManager.sharedInstance.deleteTorrent(model.id) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.selectBehaviour?.deselect()
                }
            }
        }
    }
}
