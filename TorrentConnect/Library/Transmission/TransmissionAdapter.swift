//
//  TransmissionConnector.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

enum RequestError {
    case AuthorizationError
    case ParseError
    case FileError(String)
}

struct TransmissionAdapter {
    let parser = TransmissionParser()
    let rpc = TransmissionRpc()
    
    private func postRequest(url: NSURL, request: RpcRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        urlRequest.HTTPBody = request.toJson().dataUsingEncoding(NSUTF8StringEncoding)
        
        let requestTask = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: completionHandler)
        requestTask.resume()
    }
    
    private func authorizedRequest(connection: TransmissionServerConnection, request: RpcRequest, success: (NSData) -> (), error: (RequestError) -> ()) {
        let url = connection.settings.getServerUrl()
        let sessionId = connection.sessionId
        let body = request.toJson()
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        urlRequest.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        urlRequest.setValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        let requestTask = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { data, response, _ in
            if let response = response as? NSHTTPURLResponse {
                if response.statusCode == 409 {
                    error(RequestError.AuthorizationError)
                    return
                }
            }
            
            if let data = data {
                success(data)
            }
        }
        requestTask.resume()
    }
}

extension TransmissionAdapter {
    func connect(settings: ConnectionSettings, success: (TransmissionServerConnection) -> (), error: (RequestError) -> ()) {
        let url = settings.getServerUrl()
        postRequest(url, request: rpc.getSessionId()) { _, response, _ in
            if let sessionId = self.parser.getSessionId(response) {
                let connection = TransmissionServerConnection(settings: settings, sessionId: sessionId)
                success(connection)
            }
        }
    }
    
    func torrents(connection: TransmissionServerConnection, success: ([Torrent]) -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.getTorrents(), success: { data in
            switch self.parser.getTorrents(data) {
            case .First(let torrents):
                success(torrents)
            case .Second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func stop(connection: TransmissionServerConnection, ids: [Int], success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.stopTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func start(connection: TransmissionServerConnection, ids: [Int], success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.startTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func add(connection: TransmissionServerConnection, url: String, paused: Bool, success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.addTorrent(url: url, paused: paused), success: { _ in success() }, error: error)
    }
    
    func add(connection: TransmissionServerConnection, filename: String, paused: Bool, success: () -> (), error: (RequestError) -> ()) {
        let trydata = NSData(contentsOfFile: filename)
        
        if let data = trydata {
            let metainfo = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            self.authorizedRequest(connection, request: rpc.addTorrent(metainfo: metainfo, paused: paused), success: { _ in success() }, error: error)
            return
        }
        error(.FileError(filename))
    }
    
    func delete(connection: TransmissionServerConnection, ids: [Int], deleteLocalData: Bool, success: () -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.deleteTorrents(ids, deleteLocalData: deleteLocalData), success: { _ in success() }, error: error)
    }
    
    func files(connection: TransmissionServerConnection, ids: [Int], success: ([TorrentFile]) -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.getTorrentFiles(ids), success: { data in
            switch self.parser.getTorrentFiles(data) {
            case .First(let files):
                success(files)
            case .Second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func move(connection: TransmissionServerConnection, ids: [Int], location: String, success: () -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.moveTorrents(ids, location: location), success: { _ in }, error: error)
    }
    
    func setFiles(connection: TransmissionServerConnection, id: Int, wanted: [Int], unwanted: [Int], success: () -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.wantFiles(forTorrent: id, wanted: wanted, unwanted: unwanted), success: { _ in success() }, error: error)
    }
}