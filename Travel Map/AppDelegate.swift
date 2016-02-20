//
//  AppDelegate.swift
//  Trax
//
//  Created by Sun liang on 1/30/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit

struct GPXURL {
    static let Notification = "GPXURL Radio Station"
    static let Key = "GPXURL URL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        // post a notification when a GPX file arrives
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.Notification, object: self, userInfo: [GPXURL.Key:url])
        center.postNotification(notification)
        return true
    }

}

