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
    
    private let _credentialsManager = CredentialsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let port = defaults.integerForKey("port")
        if let host = defaults.stringForKey("host") {
            hostField.stringValue = host
            
            if let credentials = _credentialsManager.getCredentials(host, port: port) {
                usernameField.stringValue = credentials.username
                passwordField.stringValue = credentials.password
            }
        }
        portField.integerValue = port
    }
    
    override func viewWillDisappear() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(hostField.stringValue, forKey: "host")
        defaults.setInteger(portField.integerValue, forKey: "port")
        if (usernameField.stringValue != "") {
            let credentials = Credentials(username: usernameField.stringValue, password: passwordField.stringValue)
            _credentialsManager.setCredentials(hostField.stringValue, port: portField.integerValue, credentials: credentials)
        }
    }
}
