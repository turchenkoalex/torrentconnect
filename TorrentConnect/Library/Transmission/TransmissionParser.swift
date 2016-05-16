//
//  TransmissionParser.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

class TransmissionParser {
    private func getTorrent(o: AnyObject?) -> TorrentModel? {
        let json = JSON(o)
        guard
            let id = json?["id"] as? Int,
            let name = json?["name"] as? String,
            let status = json?["status"] as? Int,
            let percentDone = json?["percentDone"] as? Double,
            let downloadDir = json?["downloadDir"] as? String
            else {
                    return nil
            }
        
        return TorrentModel(
            id: id,
            name: name,
            status: TorrentStatus(rawValue: status)!,
            progress: percentDone * 100,
            downloadDir: downloadDir)
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
    
    
    func getTorrents(data: NSData) -> Either<[TorrentModel], RequestError> {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if JSON(json)?["result"] as? String == "success" {
                if let objs = JSON(json)?["arguments"]?["torrents"] as? NSArray {
                    var torrents = [TorrentModel]()
                    for o in objs {
                        if let t = getTorrent(o) {
                            torrents.append(t)
                        }
                    }
                    return .First(torrents)
                }
            }
            return .Second(.ParseError)
        } catch {
            return .Second(.ParseError)
        }
    }
}