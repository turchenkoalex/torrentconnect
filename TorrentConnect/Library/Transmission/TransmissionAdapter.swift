//
//  TransmissionConnector.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

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

extension TransmissionAdapter: TorrentAdapter {
    typealias ServerConnection = TransmissionServerConnection
    
    func connect(settings: ConnectionSettings, success: (TransmissionServerConnection) -> (), error: (RequestError) -> ()) {
        let url = settings.getServerUrl()
        request(url, body: rpc.getSessionId()) { _, response, _ in
            if let sessionId = self.parser.getSessionId(response) {
                let connection = TransmissionServerConnection(settings: settings, sessionId: sessionId)
                success(connection)
            }
        }
    }
    
    func torrents(connection: TransmissionServerConnection, success: ([TorrentModel]) -> (), error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.getTorrents(), success: { data in
            switch self.parser.getTorrents(data) {
            case let .First(torrents):
                success(torrents)
            case let .Second(requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func stop(connection: TransmissionServerConnection, ids: [Int], error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.stopTorrents(ids), success: { _ in }, error: error)
    }
    
    func start(connection: TransmissionServerConnection, ids: [Int], error: (RequestError) -> ()) {
        self.authorizedRequest(connection, body: rpc.startTorrents(ids), success: { _ in }, error: error)
    }
}