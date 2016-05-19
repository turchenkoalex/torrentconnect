//
//  FilesHandler.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 19.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

struct FilesHandler {
    func openFile(filename: String) -> Bool {
        addFile(filename)
        return true
    }
    
    func openFiles(filenames: [String]) {
        for filename in filenames {
            addFile(filename)
        }
    }
    
    func addFile(filename: String) {
        TransmissionConnectManager.sharedInstance.addTorrent(filename: filename) {
            let fileUrl = NSURL(fileURLWithPath: filename)
            try! NSFileManager.defaultManager().trashItemAtURL(fileUrl, resultingItemURL: nil)
        }
    }
}