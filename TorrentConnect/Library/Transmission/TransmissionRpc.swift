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
        let fields = ["id", "name", "status", "comment", "percentDone", "downloadDir"]
        return RpcRequest(method: "torrent-get", arguments: ["fields": fields]).toJson()
    }
    
    func stopTorrents(ids: [Int]) -> String {
        return RpcRequest(method: "torrent-stop", arguments: ["ids": ids]).toJson()
    }
    
    func startTorrents(ids: [Int]) -> String {
        return RpcRequest(method: "torrent-start", arguments: ["ids": ids]).toJson()
    }
}