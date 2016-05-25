//
//  AppDelegate.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    private let _badgeController = BadgeController()
    private let _downloadedController = DownloadedController()
    private let _urlHandler = UrlHandler()
    private let _filesHandler = FilesHandler()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "host": "localhost",
            "port": 9091])
        
        _badgeController.inject()
        _downloadedController.inject()
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        let eventManager = NSAppleEventManager.sharedAppleEventManager()
        eventManager.setEventHandler(_urlHandler, andSelector: #selector(UrlHandler.openUrlEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        sender.windows.first?.makeKeyAndOrderFront(sender)
        return true
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        center.removeDeliveredNotification(notification)
        NSApplication.sharedApplication().windows.first?.makeKeyAndOrderFront(NSApplication.sharedApplication())
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        return _filesHandler.openFile(filename)
    }
    
    func application(sender: NSApplication, openFiles filenames: [String]) {
        _filesHandler.openFiles(filenames)
    }
}