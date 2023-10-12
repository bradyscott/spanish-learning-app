//
//  AppDelegate.swift
//  Los Verbos
//
//  Created by Scott Brady on 07/04/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BWWalkthroughViewControllerDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            var mainView: UIStoryboard
            mainView = UIStoryboard(name: "Main", bundle: nil)
            
            let VC: UIViewController = mainView.instantiateViewController(withIdentifier: "iPhoneStoryboard") as UIViewController
            self.window!.rootViewController = VC
            
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            
            var mainView: UIStoryboard
            mainView = UIStoryboard(name: "iPadStoryboard", bundle: nil)
            
            let VC: UIViewController = mainView.instantiateViewController(withIdentifier: "iPadStoryboard") as UIViewController
            self.window!.rootViewController = VC
            
            print("Using iPad Storyboard")
            
        }
        
        return true
        
        
    }    
    
    /*func whatsNew() {
        let alertController = UIAlertController(title: "What's new", message: "● Concurso español is now a universal app and optimised for iPad\n○ New topics: In the City & Pastimes and Hobbies\n● Larger text for the question on devices with larger screens\n○ You now select the number of questions on the same screen that you select a quiz\n● Improved animations\n○ Share your score to Facebook, Twitter and more when you finish a quiz\n● Improved tutorial\n○ Fixed a bug that, in rare cases, caused the percentage and hence grade to be calculated incorrectly", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Start Tutorial", style: .default, handler: { action in
            self.tutorial()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }*/

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

