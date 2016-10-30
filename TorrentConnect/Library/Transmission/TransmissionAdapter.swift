//
//  TransmissionConnector.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

enum RequestError {
    case authorizationError
    case parseError
    case fileError(String)
}

struct TransmissionAdapter {
    let parser = TransmissionParser()
    let rpc = TransmissionRpc()
    
    fileprivate let _credentialsManager = CredentialsManager()
    
    fileprivate func getBasicHeader(_ host: String, port: Int) -> String? {
        if let credentials = _credentialsManager.getCredentials(host, port: port) {
            let loginString = "\(credentials.username):\(credentials.password)"
            let loginData = loginString.data(using: String.Encoding.utf8)
            let base64EncodedCredential = loginData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            return "Basic \(base64EncodedCredential)"
        }
        
        return nil
    }
    
    fileprivate func setupAuthorization(_ request: URLRequest) -> URLRequest {
        var newRequst = request
        if let url = newRequst.url {
            if let basicHeader = getBasicHeader(url.host!, port: (url as NSURL).port!.intValue) {
                newRequst.setValue(basicHeader, forHTTPHeaderField: "Authorization")
            }
        }
        
        return newRequst
    }
    
    fileprivate func postRequest(_ url: URL, request: RpcRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.toJson().data(using: String.Encoding.utf8)
        urlRequest = setupAuthorization(urlRequest)
        
        let requestTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
        requestTask.resume()
    }
    
    fileprivate func authorizedRequest(_ connection: TransmissionServerConnection, request: RpcRequest, success: @escaping (Data) -> (), error: @escaping (RequestError) -> ()) {
        let url = connection.settings.getServerUrl()
        let sessionId = connection.sessionId
        let body = request.toJson()
        var urlRequest = URLRequest(url: url as URL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body.data(using: String.Encoding.utf8)
        urlRequest = setupAuthorization(urlRequest)
        urlRequest.setValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        let requestTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, _ in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 409 || response.statusCode == 401 {
                    error(RequestError.authorizationError)
                    return
                }
            }
            
            if let data = data {
                success(data)
            }
        }) 
        requestTask.resume()
    }
}

extension TransmissionAdapter {
    func connect(_ settings: ConnectionSettings, success: @escaping (TransmissionServerConnection) -> (), error: @escaping (RequestError) -> ()) {
        let url = settings.getServerUrl()
        postRequest(url as URL, request: rpc.getSessionId()) { _, response, _ in
            if let sessionId = self.parser.getSessionId(response) {
                let connection = TransmissionServerConnection(settings: settings, sessionId: sessionId)
                success(connection)
            } else {
                error(.authorizationError)
            }
        }
    }
    
    func torrents(_ connection: TransmissionServerConnection, success: @escaping ([Torrent]) -> (), error: @escaping (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.getTorrents(), success: { data in
            switch self.parser.getTorrents(data) {
            case .first(let torrents):
                success(torrents)
            case .second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func stop(_ connection: TransmissionServerConnection, ids: [Int], success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.stopTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func start(_ connection: TransmissionServerConnection, ids: [Int], success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.startTorrents(ids), success: { _ in success() }, error: error)
    }
    
    func add(_ connection: TransmissionServerConnection, url: String, paused: Bool, success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        self.authorizedRequest(connection, request: rpc.addTorrent(url: url, paused: paused), success: { _ in success() }, error: error)
    }
    
    func add(_ connection: TransmissionServerConnection, filename: String, paused: Bool, success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        let trydata = try? Data(contentsOf: URL(fileURLWithPath: filename))
        
        if let data = trydata {
            let metainfo = data.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
            self.authorizedRequest(connection, request: rpc.addTorrent(metainfo: metainfo, paused: paused), success: { _ in success() }, error: error)
            return
        }
        error(.fileError(filename))
    }
    
    func delete(_ connection: TransmissionServerConnection, ids: [Int], deleteLocalData: Bool, success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.deleteTorrents(ids, deleteLocalData: deleteLocalData), success: { _ in success() }, error: error)
    }
    
    func files(_ connection: TransmissionServerConnection, ids: [Int], success: @escaping ([TorrentFile]) -> (), error: @escaping (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.getTorrentFiles(ids), success: { data in
            switch self.parser.getTorrentFiles(data) {
            case .first(let files):
                success(files)
            case .second(let requestError):
                error(requestError)
            }
        }, error: error)
    }
    
    func move(_ connection: TransmissionServerConnection, ids: [Int], location: String, success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.moveTorrents(ids, location: location), success: { _ in }, error: error)
    }
    
    func setFiles(_ connection: TransmissionServerConnection, id: Int, wanted: [Int], unwanted: [Int], success: @escaping () -> (), error: @escaping (RequestError) -> ()) {
        authorizedRequest(connection, request: rpc.wantFiles(forTorrent: id, wanted: wanted, unwanted: unwanted), success: { _ in success() }, error: error)
    }
}
