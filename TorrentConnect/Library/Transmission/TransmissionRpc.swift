//
//  TransmissionRpc.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct RpcRequest {
    let method: String
    let arguments: [String: JsonPrintable]
    
    func toJson() -> String {
        if (arguments.isEmpty) {
            return JsonObject(attributes: ["method": method]).toJson()
        }
        
        return JsonObject(attributes: ["method": method, "arguments": arguments]).toJson()
    }
}

struct TransmissionRpc {
    func getSessionId() -> String {
        return RpcRequest(method: "session-get", arguments: [:]).toJson()
    }
    
    func getTorrents() -> String {
        let fields = ["id", "name", "status", "comment", "percentDone", "downloadDir", "rateDownload", "rateUpload", "totalSize", "leftUntilDone", "queuePosition"]
        return RpcRequest(method: "torrent-get", arguments: ["fields": fields]).toJson()
    }
    
    func getTorrentFiles(ids: [Int]) -> String {
        let fields = ["id", "files", "fileStats"]
        return RpcRequest(method: "torrent-get", arguments: ["ids": ids, "fields": fields]).toJson()
    }
    
    func stopTorrents(ids: [Int]) -> String {
        return RpcRequest(method: "torrent-stop", arguments: ["ids": ids]).toJson()
    }
    
    func startTorrents(ids: [Int]) -> String {
        return RpcRequest(method: "torrent-start", arguments: ["ids": ids]).toJson()
    }
    
    func addTorrent(url url: String, paused: Bool) -> String {
        return RpcRequest(method: "torrent-add", arguments: ["paused": paused, "filename": url]).toJson()
    }
    
    func addTorrent(metainfo metainfo: String, paused: Bool) -> String {
        return RpcRequest(method: "torrent-add", arguments: ["paused": paused, "metainfo": metainfo]).toJson()
    }
    
    func deleteTorrents(ids: [Int], deleteLocalData: Bool) -> String {
        return RpcRequest(method: "torrent-remove", arguments: ["ids": ids, "delete-local-data": deleteLocalData]).toJson()
    }
    
    func moveTorrents(ids: [Int], location: String) -> String {
        return RpcRequest(method: "torrent-set-location", arguments: ["ids": ids, "location": location, "move": true]).toJson()
    }
}