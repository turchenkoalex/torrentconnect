//
//  FilesHandler.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 19.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

struct FilesHandler {
    func openFile(_ filename: String) -> Bool {
        addFile(filename)
        return true
    }
    
    func openFiles(_ filenames: [String]) {
        for filename in filenames {
            addFile(filename)
        }
    }
    
    func addFile(_ filename: String) {
        TransmissionConnectManager.shared.addTorrent(filename: filename) {
            let fileUrl = URL(fileURLWithPath: filename)
            try! FileManager.default.trashItem(at: fileUrl, resultingItemURL: nil)
        }
    }
}
