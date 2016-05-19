//
//  ConnectionSettings.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

struct ConnectionSettings {
    let torrentServerType: TorrentServerType = .Transmission
    let scheme: String
    let host: String
    let port: Int
    let path: String
}

extension ConnectionSettings {
    func getServerUrl() -> NSURL {
        let component = NSURLComponents()
        component.scheme = scheme
        component.host = host
        component.port = port
        component.path = path
        return component.URL!
    }
}