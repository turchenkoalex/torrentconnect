//
//  TransmissionParser.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

struct TransmissionParser {
    private func parseTorrent(o: AnyObject?) -> Torrent? {
        let json = JSON(o)
        guard
            let id = json?["id"] as? Int,
            let name = json?["name"] as? String,
            let status = json?["status"] as? Int,
            let percentDone = json?["percentDone"] as? Double,
            let downloadDir = json?["downloadDir"] as? String,
            let position = json?["queuePosition"] as? Int
            else {
                    return nil
            }
        
        return Torrent(
            id: id,
            name: name,
            status: TorrentStatus(rawValue: status)!,
            progress: percentDone,
            downloadDir: downloadDir,
            position: position)
    }
    
    private func parseTorrentFiles(o: AnyObject?) -> [TorrentFile]? {
        let json = JSON(o)
        guard
            let torrentId = json?["id"] as? Int,
            let jsonFiles = json?["files"] as? NSArray,
            let jsonStats = json?["fileStats"] as? NSArray
        else {
            return nil
        }
        
        var files = [TorrentFile]()
        
        for (id, jsonFile) in jsonFiles.enumerate() {
            let jsonStat = jsonStats.objectAtIndex(id)
            if let file = parseTorrentFile(id, torrentId: torrentId, file: jsonFile, stats: jsonStat) {
                files.append(file)
            }
        }
        
        return files
    }
    
    private func parseTorrentFile(id: Int, torrentId: Int, file: AnyObject?, stats: AnyObject?) -> TorrentFile? {
        let json = JSON(file)
        guard
            let name = json?["name"] as? String,
            let length = json?["length"] as? Int,
            let bytesCompleted = json?["bytesCompleted"] as? Int
            else {
                return nil
        }
        
        let wants = JSON(stats)?["wanted"] as? Bool ?? false
        
        return TorrentFile(
            id: id,
            torrentId: torrentId,
            name: name,
            length: length,
            bytesCompleted: bytesCompleted,
            wants: wants)
    }
    
    func getSessionId(response: NSURLResponse?) -> String? {
        if let response = response as? NSHTTPURLResponse {
            if response.statusCode == 409 {
                if let sessionId = response.allHeaderFields["X-Transmission-Session-Id"] as? String {
                    return sessionId
                }
            }
        }
        return nil
    }
    
    private func getObjects<T>(data: NSData, section: String, parseItem: (AnyObject?) -> (T?)) -> Either<[T], RequestError> {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if JSON(json)?["result"] as? String == "success" {
                if let jsonItems = JSON(json)?["arguments"]?[section] as? NSArray {
                    var items = [T]()
                    for jsonItem in jsonItems {
                        if let item = parseItem(jsonItem) {
                            items.append(item)
                        }
                    }
                    return .First(items)
                }
            }
            return .Second(.ParseError)
        } catch {
            return .Second(.ParseError)
        }
    }
    
    func getTorrents(data: NSData) -> Either<[Torrent], RequestError> {
        return getObjects(data, section: "torrents", parseItem: parseTorrent)
    }
    
    private func acc(acc: [TorrentFile], val: [TorrentFile]) -> [TorrentFile] {
        var newAcc = [TorrentFile](acc)
        newAcc.appendContentsOf(val)
        return newAcc
    }
    
    func getTorrentFiles(data: NSData) -> Either<[TorrentFile], RequestError> {
        let allFiles = getObjects(data, section: "torrents", parseItem: parseTorrentFiles)
        switch allFiles {
        case .First(let torrents):
            return .First(torrents.reduce([], combine: acc))
        case .Second(let error):
            return .Second(error)
        }
    }
}