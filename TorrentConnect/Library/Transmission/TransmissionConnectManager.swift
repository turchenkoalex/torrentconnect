//
//  TransmissionConnectManager.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

@objc public class TransmissionConnectManager: NSObject {
    
    public static let sharedInstance = TransmissionConnectManager()
    
    private var _connection: TransmissionServerConnection?
    private let _adapter: TransmissionAdapter = TransmissionAdapter()
    private var _timer: NSTimer?
    
    public let fetchTorrentsEvent = Event<[TorrentModel]>()
    
    func getSettings() -> ConnectionSettings {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let host = defaults.stringForKey("host") ?? "127.0.0.1"
        let port = defaults.integerForKey("port")
        
        return ConnectionSettings(scheme: "http", host: host, port: port, path: "/transmission/rpc")
    }
    
    func connect() {
        _timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(TransmissionConnectManager.fetchTorrents), userInfo: nil, repeats: true)
        _adapter.connect(getSettings(), success: connectSuccess, error: connectError)
    }
    
    func connectSuccess(connection: TransmissionServerConnection) {
        self._connection = connection
        self.fetchTorrents()
    }
    
    func connectError(error: RequestError) {
        print(error)
    }
    
    public func fetchTorrents() {
        if let connection = _connection {
            self._adapter.torrents(connection, success: self.fetchTorrentsSuccess, error: requestError)
        } else {
            connect()
        }
    }
    
    func fetchTorrentsSuccess(torrents: [TorrentModel]) {
        fetchTorrentsEvent.raise(torrents)
    }
    
    func requestError(error: RequestError) {
        if error == RequestError.AuthorizationError {
            connect()
        }
    }
    
    public func startTorrents(ids: [Int]) {
        if let connection = _connection {
            self._adapter.start(connection, ids: ids, error: requestError)
        }
    }
    
    public func stopTorrents(ids: [Int]) {
        if let connection = _connection {
            self._adapter.stop(connection, ids: ids, error: requestError)
        }
    }
}