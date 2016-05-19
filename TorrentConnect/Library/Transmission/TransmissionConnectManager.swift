//
//  TransmissionConnectManager.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

struct EventQueue {
    var _events: [() -> ()] = []
    
    mutating func add(event: () -> ()) {
        _events.append(event)
    }
    
    mutating func invoke() {
        while (_events.count > 0) {
            _events.removeFirst()()
        }
    }
}

@objc public class TransmissionConnectManager: NSObject {
    
    private var _events = EventQueue()
    public static let sharedInstance = TransmissionConnectManager()
    
    private var _connection: TransmissionServerConnection?
    private let _adapter = TransmissionAdapter()
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
        self._events.invoke()
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
        switch error {
        case .AuthorizationError:
            connect()
        default:
            print(error)
        }
    }
    
    public func startTorrents(ids: [Int], success: () -> ()) {
        if let connection = _connection {
            self._adapter.start(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    public func stopTorrents(ids: [Int], success: () -> ()) {
        if let connection = _connection {
            self._adapter.stop(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    private func isPausedSetting() -> Bool {
        return false
    }
    
    public func addTorrent(url url: String, success: () -> ()) {
        if let connection = _connection {
            self._adapter.add(connection, url: url, paused: isPausedSetting(), success: success, error: requestError)
        } else {
            _events.add {
                self.addTorrent(url: url, success: success)
            }
        }
    }
    
    public func addTorrent(filename filename: String, success: () -> ()) {
        if let connection = _connection {
            self._adapter.add(connection, filename: filename, paused: isPausedSetting(), success: success, error: requestError)
        } else {
            _events.add {
                self.addTorrent(filename: filename, success: success)
            }
        }
    }
    
    private func isDeleteLocalData() -> Bool {
        return true
    }
    
    public func deleteTorrent(id: Int, success: () -> ()) {
        deleteTorrents([id], success: success)
    }
    
    public func deleteTorrents(ids: [Int], success: () -> ()) {
        if let connection = _connection {
            self._adapter.delete(connection, ids: ids, deleteLocalData: isDeleteLocalData(), success: {
                self.fetchTorrents()
                success()
            }, error: requestError)
        }
    }
}