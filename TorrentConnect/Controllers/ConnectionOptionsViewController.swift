//
//  ConnectionOptionsViewController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 27.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class ConnectionOptionsViewController: NSViewController {

    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    private func getSpace(host host: String, port: Int) -> NSURLProtectionSpace {
        return NSURLProtectionSpace(host: host, port: port, protocol: "http", realm: "Transmission", authenticationMethod: NSURLAuthenticationMethodDefault)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let port = defaults.integerForKey("port")
        if let host = defaults.stringForKey("host") {
            hostField.stringValue = host
            
            let space = getSpace(host: host, port: port)
            if let credential = NSURLCredentialStorage.sharedCredentialStorage().defaultCredentialForProtectionSpace(space) {
                usernameField.stringValue = credential.user!
                passwordField.stringValue = credential.password!
            }
        }
        portField.integerValue = port
    }
    
    override func viewWillDisappear() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(hostField.stringValue, forKey: "host")
        defaults.setInteger(portField.integerValue, forKey: "port")
        if (usernameField.stringValue != "") {
            let space = getSpace(host: hostField.stringValue, port: portField.integerValue)
            let credential = NSURLCredential(user: usernameField.stringValue, password: passwordField.stringValue, persistence: .Permanent)
            NSURLCredentialStorage.sharedCredentialStorage().setDefaultCredential(credential, forProtectionSpace: space)
        }
    }
}
