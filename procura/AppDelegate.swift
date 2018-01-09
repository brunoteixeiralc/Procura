//
//  AppDelegate.swift
//  procura
//
//  Created by Bruno Lemgruber on 09/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        customizeApparence()
        return true
    }
    
    func customizeApparence(){
        let barTintColor = UIColor(red: 46/255, green: 204/255,
                                   blue: 113/255, alpha: 1)
        UISearchBar.appearance().barTintColor = barTintColor
        window?.tintColor = UIColor(red: 0/255, green: 0/255,
                                    blue: 0/255, alpha: 1)
    }
}

