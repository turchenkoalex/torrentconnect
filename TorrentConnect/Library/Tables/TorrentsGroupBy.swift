//
//  TorrentsGroupBy.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct TorrentsGroupBy {
    let other = "Other"
    let movies = "Movies"
    let shows = "Shows"
    let music = "Music"
 
    private func byDownloadDirKeySelector(element: Torrent) -> String {
        if (element.downloadDir == "/downloads/movies") {
            return movies
        }
        
        if (element.downloadDir == "/downloads/shows") {
            return shows
        }
        
        if (element.downloadDir == "/downloads/music") {
            return music
        }
        
        return other
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