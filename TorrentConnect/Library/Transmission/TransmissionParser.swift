//
//  TransmissionParser.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

struct TransmissionParser {
    fileprivate func parseTorrent(_ json: JSON) -> Torrent? {
        
        guard
            let id = json["id"].int,
            let name = json["name"].string,
            let status = json["status"].int,
            let percentDone = json["percentDone"].double,
            let downloadDir = json["downloadDir"].string,
            let position = json["queuePosition"].int
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
    
    fileprivate func parseTorrentFiles(_ json: JSON) -> [TorrentFile]? {
        guard
            let torrentId = json["id"].int,
            let jsonFiles = json["files"].array,
            let jsonStats = json["fileStats"].array
        else {
            return nil
        }
        
        var files = [TorrentFile]()
        
        for (id, jsonFile) in jsonFiles.enumerated() {
            let jsonStat = jsonStats[id]
            if let file = parseTorrentFile(id, torrentId: torrentId, file: jsonFile, stats: jsonStat) {
                files.append(file)
            }
        }
        
        return files
    }
    
    fileprivate func parseTorrentFile(_ id: Int, torrentId: Int, file: JSON, stats: JSON) -> TorrentFile? {
        guard
            let name = file["name"].string,
            let length = file["length"].int,
            let bytesCompleted = file["bytesCompleted"].int
            else {
                return nil
        }
        
        let wants = stats["wanted"].bool ?? false
        
        return TorrentFile(
            id: id,
            torrentId: torrentId,
            name: name,
            length: length,
            bytesCompleted: bytesCompleted,
            wants: wants)
    }
    
    func getSessionId(_ response: URLResponse?) -> String? {
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 409 {
                if let sessionId = response.allHeaderFields["X-Transmission-Session-Id"] as? String {
                    return sessionId
                }
            }
        }
        return nil
    }
    
    fileprivate func getObjects<T>(_ data: Data, section: String, parseItem: (JSON) -> (T?)) -> Either<[T], RequestError> {
        let json = JSON(data: data)
        if json["result"].stringValue == "success" {
            if let arguments = json["arguments"][section].array {
                var items = [T]()
                for argument in arguments {
                    if let item = parseItem(argument) {
                        items.append(item)
                    }
                }
                return .first(items)
            }
            return .first([T]())
        }
        return .second(.parseError)
    }
    
    func getTorrents(_ data: Data) -> Either<[Torrent], RequestError> {
        return getObjects(data, section: "torrents", parseItem: parseTorrent)
    }
    
    fileprivate func acc(_ acc: [TorrentFile], val: [TorrentFile]) -> [TorrentFile] {
        var newAcc = [TorrentFile](acc)
        newAcc.append(contentsOf: val)
        return newAcc
    }
    
    func getTorrentFiles(_ data: Data) -> Either<[TorrentFile], RequestError> {
        let allFiles = getObjects(data, section: "torrents", parseItem: parseTorrentFiles)
        switch allFiles {
        case .first(let torrents):
            return .first(torrents.reduce([], acc))
        case .second(let error):
            return .second(error)
        }
    }
}
