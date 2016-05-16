//
//  AssetIdentifiers.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 24.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

extension NSImage {
    enum AssetIdentifier: String {
        case Wait = "wait"
        case Completed = "completed"
        case Download = "download"
        case Upload = "upload"
        case Box = "box"
        case DisabledBox = "box-disabled"
        case Folder = "folder"
        case DisabledFolder = "folder-disabled"
        case Play = "play"
        case Pause = "pause"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}