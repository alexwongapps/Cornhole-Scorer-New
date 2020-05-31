//
//  AppDelegate.swift
//  Cornhole
//
//  Created by Alex Wong on 7/2/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseUI
import FirebaseAuth
import KeychainSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UserDefaults.standard.register(defaults: [
            "gameType": 0,
            "winningScore": 21,
            "bustScore": 15,
            "roundLimit": 10,
            "firstThrowWinners": true,
            "activeLeagueID": CornholeFirestore.TEST_LEAGUE_ID,
            "alreadyLaunched30": false,
            "alreadyLaunched30EL": false,
            "alreadyLaunched30LD": false
            ])
        FirebaseApp.configure()
        
        if CommandLine.arguments.contains("--uitesting") {
            resetToUIState()
            return true
        }
        
        let keychain = KeychainSwift()
        keychain.accessGroup = "H5H633W272.CornholeScorer"
        if let lP = keychain.getBool("leaguesPaid") {
            leaguesPaid = lP
        }
        
        if let pP = keychain.getBool("proPaid") {
            proPaid = pP
        }
        
        return true
    }
    
    func resetToUIState() {
        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
        coreDataDeleteAll(entity: "Matches")
        coreDataDeleteAll(entity: "Players")
        UserDefaults.standard.set(true, forKey: "alreadyLaunched")
        UserDefaults.standard.set(true, forKey: "alreadyLaunched30")
        UserDefaults.standard.set(true, forKey: "alreadyLaunched30EL")
        UserDefaults.standard.set(true, forKey: "alreadyLaunched30LD")
        leaguesPaid = true
        proPaid = true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if !isLeagueActive() {
            if url.pathExtension == "corn" {
                Match.importData(from: url)
                if let tabVC = self.window?.rootViewController as? UITabBarController {
                    tabVC.selectedIndex = MATCHES_TAB_INDEX
                }
                
                guard let tabVC = self.window?.rootViewController as? UITabBarController,
                    let matchesViewController = tabVC.selectedViewController as? MatchesViewController else {
                    return true
                }
                matchesViewController.viewWillAppear(true)
            } else { // auth
                let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
                if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
                    return true
                }
                return false
            }
        } else {
            if let tabVC = self.window?.rootViewController as? UITabBarController {
                tabVC.selectedIndex = MATCHES_TAB_INDEX
            }
            
            guard let tabVC = self.window?.rootViewController as? UITabBarController,
                let matchesViewController = tabVC.selectedViewController as? MatchesViewController else {
                return true
            }
            matchesViewController.viewWillAppear(true)
            matchesViewController.present(createBasicAlert(title: "Unable to import", message: "Cannot share matches to a league. Please log out to import this match"), animated: true, completion: nil)
        }
        return true
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        IAPManager.shared.stopObserving()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.kidscancode.CornholeScorer.goToScoreboard" {
            entryTab = SCOREBOARD_TAB_INDEX
        } else if shortcutItem.type == "com.kidscancode.CornholeScorer.goToMatches" {
            entryTab = MATCHES_TAB_INDEX
        } else if shortcutItem.type == "com.kidscancode.CornholeScorer.goToStats" {
            entryTab = STATS_TAB_INDEX
        }
        
        if let tabVC = self.window?.rootViewController as? UITabBarController {
            tabVC.selectedIndex = entryTab
            
            switch entryTab {
            case MATCHES_TAB_INDEX:
                
                guard let tabVC = self.window?.rootViewController as? UITabBarController,
                    let matchesViewController = tabVC.selectedViewController as? MatchesViewController else {
                    return
                }
                
                if isLeagueActive() {
                    matchesViewController.activityIndicator.startAnimating()
                    CornholeFirestore.pullLeagues(ids: [UserDefaults.getActiveLeagueID()]) { (leagues, error) in
                        matchesViewController.activityIndicator.stopAnimating()
                        if error != nil {
                            matchesViewController.present(createBasicAlert(title: "Error", message: "Unable to pull league"), animated: true, completion: nil)
                        } else {
                            print(cachedLeagues.count)
                            matchesViewController.viewDidLoad()
                            matchesViewController.viewWillAppear(true)
                        }
                    }
                }
                
            case STATS_TAB_INDEX:
                
                guard let tabVC = self.window?.rootViewController as? UITabBarController,
                    let statsViewController = tabVC.selectedViewController as? StatsViewController else {
                    return
                }
                
                if isLeagueActive() {
                    statsViewController.refresh()
                }
            default:
                print("defaults")
            }
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Cornhole")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

