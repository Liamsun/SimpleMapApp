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


    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        // post a notification when a GPX file arrives
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: GPXURL.Notification), object: self, userInfo: [GPXURL.Key:url])
        center.post(notification)
        return true
    }

}

