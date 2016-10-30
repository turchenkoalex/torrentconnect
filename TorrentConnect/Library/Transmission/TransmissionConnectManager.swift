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
    
    mutating func add(_ event: @escaping () -> ()) {
        _events.append(event)
    }
    
    mutating func invoke() {
        while (_events.count > 0) {
            _events.removeFirst()()
        }
    }
}

@objc open class TransmissionConnectManager: NSObject {
    
    fileprivate var _events = EventQueue()
    open static let sharedInstance = TransmissionConnectManager()
    
    fileprivate var _connection: TransmissionServerConnection?
    fileprivate let _adapter = TransmissionAdapter()
    fileprivate var _timer: Timer?
    fileprivate var _connectAttemps: Int = 0
    
    open let fetchTorrentsEvent = Event<[Torrent]>()
    
    func getSettings() -> ConnectionSettings {
        
        let defaults = UserDefaults.standard
        let host = defaults.string(forKey: "host") ?? "127.0.0.1"
        let port = defaults.integer(forKey: "port")
        
        return ConnectionSettings(scheme: "http", host: host, port: port, path: "/transmission/rpc")
    }
    
    func connect() {
        print("connect attemp")
        
        //self._connectAttemps += 1
        
//        if (self._connectAttemps > 10) {
//            print("Maximum connect attempts")
//            _timer?.invalidate()
//            return
//        }
        
        _timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TransmissionConnectManager.fetchTorrents), userInfo: nil, repeats: true)
        _adapter.connect(getSettings(), success: connectSuccess, error: connectError)
    }
    
    func connectSuccess(_ connection: TransmissionServerConnection) {
        print("connect success")
        
        self._connectAttemps = 0
        self._connection = connection
        self._events.invoke()
        self.fetchTorrents()
    }
    
    func connectError(_ error: RequestError) {
        print(error)
    }
    
    open func fetchTorrents() {
        if let connection = _connection {
            self._adapter.torrents(connection, success: self.fetchTorrentsSuccess, error: requestError)
        } else {
            connect()
        }
    }
    
    func fetchTorrentsSuccess(_ torrents: [Torrent]) {
        fetchTorrentsEvent.raise(torrents)
    }
    
    func requestError(_ error: RequestError) {
        switch error {
        case .authorizationError:
            connect()
        default:
            print(error)
        }
    }
    
    open func startTorrents(_ ids: [Int], success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.start(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    open func stopTorrents(_ ids: [Int], success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.stop(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    fileprivate func isPausedSetting() -> Bool {
        return false
    }
    
    open func addTorrent(url: String, success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.add(connection, url: url, paused: isPausedSetting(), success: success, error: requestError)
        } else {
            _events.add {
                self.addTorrent(url: url, success: success)
            }
        }
    }
    
    open func addTorrent(filename: String, success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.add(connection, filename: filename, paused: isPausedSetting(), success: success, error: requestError)
        } else {
            _events.add {
                self.addTorrent(filename: filename, success: success)
            }
        }
    }
    
    open func getFiles(_ ids: [Int], success: @escaping ([TorrentFile]) -> ()) {
        if let connection = _connection {
            self._adapter.files(connection, ids: ids, success: success, error: requestError)
        }
    }
    
    fileprivate func isDeleteLocalData() -> Bool {
        return true
    }
    
    open func deleteTorrents(_ ids: [Int], success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.delete(connection, ids: ids, deleteLocalData: isDeleteLocalData(), success: {
                success()
                self.fetchTorrents()
            }, error: requestError)
        }
    }
    
    open func moveTorrents(_ ids: [Int], location: String, success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.move(connection, ids: ids, location: location, success: {
                self.fetchTorrents()
                success()
            }, error: requestError)
        }
    }
    
    open func wantFiles(forTorrent id: Int, wanted: [Int], unwanted: [Int], success: @escaping () -> ()) {
        if let connection = _connection {
            self._adapter.setFiles(connection, id: id, wanted: wanted, unwanted: unwanted, success: {
                //self.fetchTorrents()
                success()
            }, error: requestError)
        }
    }
}
