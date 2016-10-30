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
    func getSessionId() -> RpcRequest {
        return RpcRequest(method: "session-get", arguments: [:])
    }
    
    func getTorrents() -> RpcRequest {
        let fields = ["id", "name", "status", "percentDone", "downloadDir", "rateDownload", "rateUpload", "totalSize", "leftUntilDone", "queuePosition"]
        return RpcRequest(method: "torrent-get", arguments: ["fields": fields])
    }
    
    func getTorrentFiles(_ ids: [Int]) -> RpcRequest {
        let fields = ["id", "files", "fileStats"]
        return RpcRequest(method: "torrent-get", arguments: ["ids": ids, "fields": fields])
    }
    
    func stopTorrents(_ ids: [Int]) -> RpcRequest {
        return RpcRequest(method: "torrent-stop", arguments: ["ids": ids])
    }
    
    func startTorrents(_ ids: [Int]) -> RpcRequest {
        return RpcRequest(method: "torrent-start", arguments: ["ids": ids])
    }
    
    func addTorrent(url: String, paused: Bool) -> RpcRequest {
        return RpcRequest(method: "torrent-add", arguments: ["paused": paused, "filename": url])
    }
    
    func addTorrent(metainfo: String, paused: Bool) -> RpcRequest {
        return RpcRequest(method: "torrent-add", arguments: ["paused": paused, "metainfo": metainfo])
    }
    
    func deleteTorrents(_ ids: [Int], deleteLocalData: Bool) -> RpcRequest {
        return RpcRequest(method: "torrent-remove", arguments: ["ids": ids, "delete-local-data": deleteLocalData])
    }
    
    func moveTorrents(_ ids: [Int], location: String) -> RpcRequest {
        return RpcRequest(method: "torrent-set-location", arguments: ["ids": ids, "location": location, "move": true])
    }
    
    func wantFiles(forTorrent id: Int, wanted: [Int], unwanted: [Int]) -> RpcRequest {
        var args: [String : JsonPrintable] = ["ids": [id]]
        if wanted.count > 0 {
            args["files-wanted"] = wanted
        }
        if unwanted.count > 0 {
            args["files-unwanted"] = unwanted
        }
        
        return RpcRequest(method: "torrent-set", arguments: args)
    }
}
