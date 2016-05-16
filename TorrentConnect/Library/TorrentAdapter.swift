//
//  TorrentConnector.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

enum RequestError {
    case AuthorizationError
    case ParseError
}

protocol TorrentAdapter {
    associatedtype ServerConnection
    
    func connect(settings: ConnectionSettings, success: (ServerConnection) -> (), error: (RequestError) -> ())
    func torrents(connection: ServerConnection, success: ([TorrentModel]) -> (), error: (RequestError) -> ())
    func stop(connection: ServerConnection, ids: [Int], error: (RequestError) -> ())
    func start(connection: ServerConnection, ids: [Int], error: (RequestError) -> ())
}