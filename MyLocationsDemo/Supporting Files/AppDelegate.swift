//
//  AppDelegate.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/6/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var perisistenetContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("couldnlt load data store: \(error)")
            }
        })
        return container
    }()

    lazy var managedObjecetContext: NSManagedObjectContext = perisistenetContainer.viewContext
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        customizeTabAndNavigationBar()
        
        print(appDocumentsDirectory)
        
        let tabController = window?.rootViewController as! UITabBarController
        
        if let tabViewControllers = tabController.viewControllers {
        
            //pass maangedObjectContext to CurrentLocationViewController
            var navController = tabViewControllers[0] as! UINavigationController
            let currentLocationController = navController.viewControllers.first as! CurrentLocationViewController
            currentLocationController.managedObjectContext = managedObjecetContext
            
            //pass maangedObjectContext to LocationViewController
            navController = tabViewControllers[1] as! UINavigationController
            let locationController = navController.viewControllers.first as! LocationViewController
            locationController.managedObjectContex = managedObjecetContext
            //force locationViewController to load views to fix presistant cach error
            let _ = locationController.view
            
            //pass maangedObjectContext to MapViewController
            navController = tabViewControllers[2] as! UINavigationController
            let mapController = navController.viewControllers.first as! MapViewController
            mapController.managedObjectContext = managedObjecetContext
            
        }
        
        //add observer for fatalCoreDataError
        listenForFatalCoreDataNotification()
        
        return true
    }

    func listenForFatalCoreDataNotification() {
        
        NotificationCenter.default.addObserver(forName: coreDataSaveFailedNotification, object: nil, queue: OperationQueue.main) { (notification) in
            
            let message = """
                There was a fatal error in the app and it can't countinue.

                Press OK to terminate the app. Sorry for the inconvenience.
                """
            
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal core data error", userInfo: nil)
                exception.raise()
            }
            
            alert.addAction(action)
        
            let tabController = self.window?.rootViewController!
            tabController?.present(alert, animated: true, completion: nil)
        }
    }
    
     func customizeTabAndNavigationBar() {
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor:
                UIColor.white ]
        
        
        UITabBar.appearance().barTintColor = .black
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0,
                                blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
