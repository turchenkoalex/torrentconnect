//
//  BadgeController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation
import AppKit

class BadgeController {
    fileprivate let _dockTile = NSDockTile()
    fileprivate var _attachedHandler: Disposable?
    
    func inject() {
        _attachedHandler = TransmissionConnectManager.shared.fetchTorrentsEvent.addHandler(self, handler: BadgeController.fetchTorrents)
    }
    
    func fetchTorrents(_ torrents: [Torrent]) {
        let downloadCount = torrents.filter { $0.status == .download }.count
        if (downloadCount > 0) {
            _dockTile.badgeLabel = String(downloadCount)
        } else {
            _dockTile.badgeLabel = nil
        }
    }
}
