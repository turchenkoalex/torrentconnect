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
    
    public let fetchTorrentsEvent = Event<[Torrent]>()
    
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
    
    func fetchTorrentsSuccess(torrents: [Torrent]) {
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
    
    public func getFiles(ids: [Int], success: ([TorrentFile]) -> ()) {
        if let connection = _connection {
            self._adapter.files(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    private func isDeleteLocalData() -> Bool {
        return true
    }
    
    public func deleteTorrents(ids: [Int], success: () -> ()) {
        if let connection = _connection {
            self._adapter.delete(connection, ids: ids, deleteLocalData: isDeleteLocalData(), success: {
                success()
                self.fetchTorrents()
            }, error: requestError)
        }
    }
    
    public func moveTorrents(ids: [Int], location: String, success: () -> ()) {
        if let connection = _connection {
            self._adapter.move(connection, ids: ids, location: location, success: {
                self.fetchTorrents()
                success()
            }, error: requestError)
        }
    }
    
    public func wantFiles(forTorrent id: Int, wanted: [Int], unwanted: [Int], success: () -> ()) {
        if let connection = _connection {
            self._adapter.setFiles(connection, id: id, wanted: wanted, unwanted: unwanted, success: {
                //self.fetchTorrents()
                success()
            }, error: requestError)
        }
    }
}