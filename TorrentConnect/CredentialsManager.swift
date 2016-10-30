//
//  CredentialsManager.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.07.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

struct Credentials {
    let username: String
    let password: String
}

struct CredentialsManager {
    fileprivate func getSpace(host: String, port: Int) -> URLProtectionSpace {
        return URLProtectionSpace(host: host, port: port, protocol: "http", realm: "Transmission", authenticationMethod: NSURLAuthenticationMethodDefault)
    }
    
    func getCredentials(_ host: String, port: Int) -> Credentials? {
        let space = getSpace(host: host, port: port)
        if let credential = URLCredentialStorage.shared.defaultCredential(for: space) {
            let username = credential.user!
            let password = credential.password!
            
            return Credentials(username: username, password: password)
        }
        
        return nil
    }
    
    func setCredentials(_ host: String, port: Int, credentials: Credentials) {
        let space = getSpace(host: host, port: port)
        let credential = URLCredential(user: credentials.username, password: credentials.password, persistence: .permanent)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: space)
    }
}
