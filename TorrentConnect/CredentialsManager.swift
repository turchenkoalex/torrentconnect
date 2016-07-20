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
    private func getSpace(host host: String, port: Int) -> NSURLProtectionSpace {
        return NSURLProtectionSpace(host: host, port: port, protocol: "http", realm: "Transmission", authenticationMethod: NSURLAuthenticationMethodDefault)
    }
    
    func getCredentials(host: String, port: Int) -> Credentials? {
        let space = getSpace(host: host, port: port)
        if let credential = NSURLCredentialStorage.sharedCredentialStorage().defaultCredentialForProtectionSpace(space) {
            let username = credential.user!
            let password = credential.password!
            
            return Credentials(username: username, password: password)
        }
        
        return nil
    }
    
    func setCredentials(host: String, port: Int, credentials: Credentials) {
        let space = getSpace(host: host, port: port)
        let credential = NSURLCredential(user: credentials.username, password: credentials.password, persistence: .Permanent)
        NSURLCredentialStorage.sharedCredentialStorage().setDefaultCredential(credential, forProtectionSpace: space)
    }
}