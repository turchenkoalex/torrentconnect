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
 
    private func byDownloadDirKeySelector(element: TorrentModel) -> String {
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
    
    func byDownloadDir() -> (([TorrentModel]) -> [(String, [TorrentModel])]) {
        return GroupBy(keySelector: self.byDownloadDirKeySelector).groupBy
    }
    
    private func byStateKeySelector(element: TorrentModel) -> String {
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
    
    func byState() -> (([TorrentModel]) -> [(String, [TorrentModel])]) {
        return GroupBy(keySelector: self.byStateKeySelector).groupBy
    }
}