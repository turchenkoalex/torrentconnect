//
//  TorrentsGroupBy.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct TorrentsGroupBy {
    fileprivate func byDownloadDirKeySelector(_ element: Torrent) -> String {
        let locations = TorrentLocations.all()
        for location in locations {
            if location.inLocation(element.downloadDir) {
                return location.name
            }
        }
        
        return "Others"
    }
    
    func byDownloadDir() -> (([Torrent]) -> [(String, [Torrent])]) {
        return GroupBy(keySelector: self.byDownloadDirKeySelector).groupBy
    }
    
    fileprivate func byStateKeySelector(_ element: Torrent) -> String {
        switch element.status {
        case .download:
            return "Download"
        case .seed:
            return "Seed"
        default:
            if (element.progress < 1) {
                return "Wait"
            } else {
                return "Completed"
            }
        }
    }
    
    func byState() -> (([Torrent]) -> [(String, [Torrent])]) {
        return GroupBy(keySelector: self.byStateKeySelector).groupBy
    }
}
