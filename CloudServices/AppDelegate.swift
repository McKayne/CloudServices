//
//  AppDelegate.swift
//  CloudServices
//
//  Created by Nikolay Taran on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var mainController: ViewController?
    
    var window: UIWindow?
    static var dropboxEmail: String? // email залогиненного в приложении пользователя
    
    // Экран залочен в портретной ориентации
    func application(_ applicaton: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    // Аутентификация
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                
                if let client = DropboxClientsManager.authorizedClient {
                    client.users.getCurrentAccount().response { response, error in
                        if let account = response {
                            print("USER")
           
                            AppDelegate.dropboxEmail = account.email
                            print(account.email)
                        }
                    }
                }
                
                let loading = LoadingIndicatorController()
                AppDelegate.mainController?.navigationController?.pushViewController(loading, animated: true)
                
                OperationQueue().addOperation {
                    // Построение дерева файлов
                    AppDelegate.mainController?.filesTree = (AppDelegate.mainController?.dropboxFilesList(path: ""))!
                    
                    sleep(5)
                    
                    DispatchQueue.main.async {
                        _ = AppDelegate.mainController?.navigationController?.popToViewController(AppDelegate.mainController!, animated: true)
                    }
                    
                }
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        return true
    }

    // Устанавливаем API key для Dropbox
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.setupWithAppKey("k6u0ir412spwuyc")
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
    }


}

