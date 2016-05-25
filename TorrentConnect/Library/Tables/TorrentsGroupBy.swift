//
//  TorrentsGroupBy.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct TorrentsGroupBy {
    private func byDownloadDirKeySelector(element: Torrent) -> String {
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
    
    private func byStateKeySelector(element: Torrent) -> String {
        switch element.status {
        case .Download:
            return "Download"
        case .Seed:
            return "Seed"
        default:
            if (element.progress < 100) {
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