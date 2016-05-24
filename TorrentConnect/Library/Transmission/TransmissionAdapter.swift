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
    
    private func request(url: NSURL, body: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let requestTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
        requestTask.resume()
    }
    
    private func authorizedRequest(connection: TransmissionServerConnection, body: String, success: (NSData) -> (), error: (RequestError) -> ()) {
        let url = connection.settings.getServerUrl()
        let sessionId = connection.sessionId
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        let requestTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, _ in
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
        request(url, body: rpc.getSessionId()) { _, response, _ in
            if let sessionId = self.parser.getSessionId(response) {
                let connection = TransmissionServerConnection(settings: settings, sessionId: sessionId)
                success(connection)
            }
        }
    }
    
    func torrents(connection: TransmissionServerConnection, success: ([Torrent]) -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.getTorrents(), success: { data in
            switch self.parser.getTorrents(data) {
            case .First(let torrents):
                success(torrents)
            case .Second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func stop(connection: TransmissionServerConnection, ids: [Int], success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.stopTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func start(connection: TransmissionServerConnection, ids: [Int], success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.startTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func add(connection: TransmissionServerConnection, url: String, paused: Bool, success: () -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.addTorrent(url: url, paused: paused), success: { _ in success() }, error: error)
    }
    
    func add(connection: TransmissionServerConnection, filename: String, paused: Bool, success: () -> (), error: (RequestError) -> ()) {
        let trydata = NSData(contentsOfFile: filename)
        
        if let data = trydata {
            let metainfo = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            self.authorizedRequest(connection, body: rpc.addTorrent(metainfo: metainfo, paused: paused), success: { _ in success() }, error: error)
            return
        }
        error(.FileError(filename))
    }
    
    func delete(connection: TransmissionServerConnection, ids: [Int], deleteLocalData: Bool, success: () -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, body: rpc.deleteTorrents(ids, deleteLocalData: deleteLocalData), success: { _ in success() }, error: error)
    }
    
    func files(connection: TransmissionServerConnection, ids: [Int], success: ([TorrentFile]) -> (), error: (RequestError) -> ()) {
        authorizedRequest(connection, body: rpc.getTorrentFiles(ids), success: { data in
            switch self.parser.getTorrentFiles(data) {
            case .First(let files):
                success(files)
            case .Second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
}