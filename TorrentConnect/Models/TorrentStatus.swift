//
//  TorrentStatus.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 24.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

enum TorrentStatus: Int {
    case Stopped       = 0
    case WaitCheck     = 1
    case Check         = 2
    case WaitDownload  = 3
    case Download      = 4
    case WaitSeed      = 5
    case Seed          = 6
}