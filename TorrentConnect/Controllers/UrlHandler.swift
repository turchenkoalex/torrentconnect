//
//  UrlHandler.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 19.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

class UrlHandler {
    @objc func openUrlEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        if let url = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            TransmissionConnectManager.sharedInstance.addTorrent(url: url, success: { 
                
            })
        }
    }
}