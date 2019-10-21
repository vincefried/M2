//
//  AppDelegate.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import UserNotifications
@_exported import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
        registerAppCenter()
        BackendWorker.shared.delegate = self
        chooseInitialViewController(isSignedIn: BackendWorker.shared.isSignedIn)
        window?.tintColor = UIColor(named: "primary")
        registerForPushNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        closeStreamIfNecessary()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        openStreamIfNecessary()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        openStreamIfNecessary()
        FriendsRequestsProvider.shared.getFriendsRequests()
        
        if let currentUser = BackendWorker.shared.currentUser,
            let deviceToken = PersistanceWorker.deviceToken {
            UsersWorker.updateDeviceToken(username: currentUser.username, deviceToken: deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        XCGLogger.default.debug("devicetoken: \(token)")
        PersistanceWorker.deviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        XCGLogger.default.debug("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        if aps["content-available"] as? Int == 1 {
            completionHandler(.newData)
        } else  {
            completionHandler(.noData)
        }
    }
    
    /// Registers the app for Apple push notifications.
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                guard let self = self else { return }
                XCGLogger.default.debug("Permission granted: \(granted)")
                
                guard granted else { return }
                
                self.getNotificationSettings()
        }
    }
    
    /// Fetches the user's notifications settings.
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            XCGLogger.default.debug("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    /// Opens the stream if necessary and sends a login command to the StreamWorker.
    private func openStreamIfNecessary() {
        if let currentUser = BackendWorker.shared.currentUser, !StreamWorker.shared.isActive {
            StreamWorker.shared.open()
            let loginCommand = OutgoingLoginStreamCommand(user: currentUser)
            StreamWorker.shared.send(streamable: loginCommand)
        }
    }
    
    /// Closes the stream if necessary and a user is signed in.
    private func closeStreamIfNecessary() {
        if BackendWorker.shared.isSignedIn && StreamWorker.shared.isActive {
            StreamWorker.shared.close()
        }
    }
    
    /// Registers the app in AppCenter.
    private func registerAppCenter() {
        MSAppCenter.start("PLACEHOLDER", withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
    }
    
    /// Transitions to a new given RootViewController.
    ///
    /// - Parameters:
    ///   - animated: If the transition should be animated.
    ///   - viewController: The new RootViewController.
    private func transitionToViewController(animated: Bool, destination viewController: UIViewController) {
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.makeKeyAndVisible()
        }
        
        if animated {
            guard let window = window,
                let rootViewController = window.rootViewController else { return }
            
            viewController.view.frame = rootViewController.view.frame
            viewController.view.layoutIfNeeded()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = viewController
            })
        } else {
            self.window?.rootViewController = viewController
        }
    }
    
    /// Chooses an initial ViewController
    /// For the use at app launch.
    ///
    /// - Parameter isSignedIn: If the user is signed in.
    private func chooseInitialViewController(isSignedIn: Bool) {
        let storyboard = UIStoryboard(name: isSignedIn ? "Main" : "Intro", bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateInitialViewController() else { return }
        
        transitionToViewController(animated: window != nil, destination: viewController)
    }
}

// MARK: - BackendWorkerDelegate
extension AppDelegate: BackendWorkerDelegate {
    func authDidChange(_ isSignedIn: Bool) {
        chooseInitialViewController(isSignedIn: isSignedIn)
    }
}
