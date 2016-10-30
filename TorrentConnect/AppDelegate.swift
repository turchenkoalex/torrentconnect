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

    fileprivate let _badgeController = BadgeController()
    fileprivate let _downloadedController = DownloadedController()
    fileprivate let _urlHandler = UrlHandler()
    fileprivate let _filesHandler = FilesHandler()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.default.delegate = self
        
        UserDefaults.standard.register(defaults: [
            "host": "localhost",
            "port": 9091])
        
        _badgeController.inject()
        _downloadedController.inject()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(_urlHandler, andSelector: #selector(UrlHandler.openUrlEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        sender.windows.first?.makeKeyAndOrderFront(sender)
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        center.removeDeliveredNotification(notification)
        NSApplication.shared().windows.first?.makeKeyAndOrderFront(NSApplication.shared())
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        return _filesHandler.openFile(filename)
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        _filesHandler.openFiles(filenames)
    }
}
