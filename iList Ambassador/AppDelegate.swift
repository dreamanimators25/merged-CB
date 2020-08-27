//
//  AppDelegate.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Flurry_iOS_SDK
import Fabric
import Crashlytics
import Firebase
import FirebaseMessaging
import UserNotifications

//let newBaseURL = "http://104.42.144.12:5000/api/" //Sameer 23/4/2020 Live Url
let newBaseURL = "http://40.112.131.121:5000/api/" //Test Server Url
let apdel = UIApplication.shared.delegate

let contentCornerRadius = CGFloat(5.0)

var isComeFromPush = false
var contentIdPush = 0
var channelIdPush = 0

var selectedRaw : Int?
var selectedSection : Int?

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    fileprivate let kFlurryKey = "B53YVH8X7K994Y2GFK79"
    static var userId: Int?
    static var token: String?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if AppManager.isFirstRun() {
            AppManager.setFirstRun()
            OAuth2Handler.sharedInstance.clearAccessToken()
        }
        
        let sessionBuilder = FlurrySessionBuilder()
            .withLogLevel(FlurryLogLevelCriticalOnly)
            .withCrashReporting(true)
        Flurry.startSession(kFlurryKey, with: sessionBuilder)
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        // Update number of sessions
        AppManager.incrementNumberOfSessions()
        debugPrint("Session number: \( AppManager.numberOfSessions() )")
        
        //Firebase
        /* Sameer 12/5/2020
        let memoryCapacity = 500 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath:"iListDish")
        URLCache.shared = urlCache
        
        // TODO: Want to remove old stuff in user defaults + core data. Maybe remove all and set boolean "migrated_to_version_3" in user defaults. If boolean exists, dont clean again..
        */
        
        // TODO: Replace all login methods and start from the beginning, this is spaghetti code.
        UserManager.sharedInstance.currentAuthorizedUser { (user) in
            print("Checking if a user exists")
            if user?.id != 0 && user != nil {
                AppDelegate.userId = user?.id
                print("User exists, so navigating to application, user id is: \(String(describing: user?.id))")
                self.navigateToApplication()
            } else {
                if let userData = CustomUserDefault.getUserData() {
                    if userData.id != 0 {
                        
                        OAuth2Handler.sharedInstance.refreshExpiredToken { (bool, acc_token, ref_token) in
                            
                            if bool {
                                OAuth2Handler.sharedInstance.update(accessToken: acc_token ?? "", refreshToken: ref_token ?? "")
                                
                                UserManager.sharedInstance.storeUserData(userData)
                                AppDelegate.userId = userData.id
                                print("User exists, so navigating to application, user id is: \(String(describing: userData.id))")
                                
                                //self.navigateToApplication()
                                //self.updatePushToken()
                                
                                DispatchQueue.main.async(execute: {
                                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                        appDelegate.navigateToApplication()
                                    }
                                })
                                
                            }else {
                                print("User id is 0, so going to login method")
                                OAuth2Handler.sharedInstance.clearAccessToken()
                                self.navigateToLogin()
                            }
                            
                        }
                        
                    }else {
                        print("User id is 0, so going to login method")
                        OAuth2Handler.sharedInstance.clearAccessToken()
                        self.navigateToLogin()
                    }
                }else {
                    
                    print("User id is 0, so going to login method")
                    OAuth2Handler.sharedInstance.clearAccessToken()
                    self.navigateToLogin()
                }
            }
        }
        
        
        //CustomUserDefault.saveUserName(name: "prateek@appin.se")
        //CustomUserDefault.saveUserPassword(password: "mobile1234")
        
        //******// 19/5/2020 Written Code from Sameer
        /*
        // TODO: Replace all login methods and start from the beginning, this is spaghetti code.
        UserManager.sharedInstance.currentAuthorizedUser { (user) in
            print("Checking if a user exists")
            if user?.id != 0 && user != nil {
                
                AppDelegate.userId = user?.id
                print("User exists, so navigating to application, user id is: \(String(describing: user?.id))")
                self.navigateToApplication()
                
            } else {
                //Sameer 16/5/2020
                //print("User id is 0, so going to login method")
                //OAuth2Handler.sharedInstance.clearAccessToken()
                //self.navigateToLogin()
                
                
                if let id = CustomUserDefault.getUserName() , id != "" {
                    print("\(id)")
                    let id = CustomUserDefault.getUserName() ?? ""
                    let pw = CustomUserDefault.getUserPassword() ?? ""
                    
                    UserManager.sharedInstance.authenticateWithUsername(id, password: pw) { (user, error, text) in
                        
                        if text != nil {
                            self.showErr(str: text!)
                        } else if error != nil {
                            self.showErr(str: "Server error")
                        } else {
                            AppDelegate.userId = user?.id
                            
                            CustomUserDefault.saveUserData(modal: user ?? User())
                            
                            print("The login was successful, so navigating to the applocation.")
                            self.updatePushToken()
                            DispatchQueue.main.async(execute: {
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    appDelegate.navigateToApplication()
                                }
                            })
                            
                        }
                    }
                    
                }else {
                    
                    print("User id is 0, so going to login method")
                    OAuth2Handler.sharedInstance.clearAccessToken()
                    self.navigateToLogin()
                    
                }
                
            }
        }
        */
        //******//
        
        //******// 19/5/2020 Written Code from client
        /*
        // TODO: Replace all login methods and start from the beginning, this is spaghetti code.
        UserManager.sharedInstance.currentAuthorizedUser { (user) in
            print("Checking if a user exists")
            if user?.id != 0 && user != nil {
                AppDelegate.userId = user?.id
                print("User exists, so navigating to application, user id is: \(String(describing: user?.id))")
                self.navigateToApplication()
            } else {
                print("User id is 0, so going to login method")
                OAuth2Handler.sharedInstance.clearAccessToken()
                self.navigateToLogin()
            }
        }
        */
        //******//
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
               // self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
            }
        }
        
        return true
    }
    
    func refreshToken() {
        
    }

    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        <#code#>
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        AppDelegate.token = fcmToken
        
//        let vc = TestViewController()
//        vc.text = fcmToken
//        window?.rootViewController?.present(vc, animated: true, completion: nil)
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String,
                                                                     annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication!,
                                                                     annotation: annotation)
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        //displaying the ios local notification when app is in foreground
//        completionHandler([.alert, .badge, .sound])
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notiData = response.notification.request.content.userInfo
        print(notiData)
        NSLog("[UserNotificationCenter] didReceiveResponse: \(notiData)")
        
        isComeFromPush = true
        
        if let dict = notiData as NSDictionary? as! [String:Any]? {
            //print(dict[key])
            NSLog("[UserNotificationCenter] dict: \(dict)")
            
            contentIdPush = (dict["gcm.notification.content_id"] as! NSString).integerValue
            channelIdPush = (dict["gcm.notification.ambassadorship"] as! NSString).integerValue
            
            if (dict["gcm.notification.type"] as! NSString).integerValue == 0 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    
                    //let nav = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrandsViewController"))
                    
                    //self.window?.rootViewController = nav
                }
                
                DispatchQueue.main.async(execute: {
                    
                    
                })
                
                // let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // let destinationViewController = storyboard.instantiateViewController(withIdentifier: "BrandsViewController") as! BrandsViewController
                // let navigationController = self.window?.rootViewController as! UINavigationController
                //   navigationController.pushViewController(nav, animated: false)
                
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let notiData = notification.request.content.userInfo
        print(notiData)
        
        NSLog("[UserNotificationCenter] willPresentNotification: \(notiData)")
        
        isComeFromPush = true
        
        if let dict = notiData as NSDictionary? as! [String:Any]? {
            //print(dict[key])
            NSLog("[UserNotificationCenter] dict: \(dict)")
            
            contentIdPush = (dict["gcm.notification.content_id"] as! NSString).integerValue
            channelIdPush = (dict["gcm.notification.ambassadorship"] as! NSString).integerValue
            
            if (dict["gcm.notification.type"] as! NSString).integerValue == 0 {
                
                DispatchQueue.main.async(execute: {
                    //let nav = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrandsViewController"))
                    
                    //self.window?.rootViewController = nav
                })
                
               // let storyboard = UIStoryboard(name: "Main", bundle: nil)
               // let destinationViewController = storyboard.instantiateViewController(withIdentifier: "BrandsViewController") as! BrandsViewController
                // let navigationController = self.window?.rootViewController as! UINavigationController
                //   navigationController.pushViewController(nav, animated: false)
                
                
                /*
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrandsViewController") as? BrandsViewController {
                    if let window = self.window, let rootViewController = window.rootViewController {
                        var currentController = rootViewController
                        while let presentedController = currentController.presentedViewController {
                            currentController = presentedController
                        }
                        currentController.present(controller, animated: true, completion: nil)
                    }
                }*/
                
            }
        }
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    // MARK: - Push notifications 
    
    func registerForPushNotifications(_ application: UIApplication) {
      //  let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
       // application.registerUserNotificationSettings(notificationSettings)
        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//            // For iOS 10 data message (sent via FCM
//            //Messaging.messaging().remoteMessageDelegate = self
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//
//        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        debugPrint("received push notification: \(userInfo)")
        
//        //creating the notification content
//        let content = UNMutableNotificationContent()
//
//        //adding title, subtitle, body and badge
//        content.title = "Hey this is Simplified iOS"
//        content.subtitle = "iOS Development is fun"
//        content.body = "We are learning about iOS Local Notification"
//        content.badge = 1
//
//        //getting the notification trigger
//        //it will be called after 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        //getting the notification request
//        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
//
//        //adding the notification to notification center
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("failed to register for push notification: \( error.localizedDescription )")
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                //print("InstanceID token: \( InstanceID.instanceID().token())")
        registerPushToken(deviceTokenString)
    }
    
    func registerPushToken(_ token: String) {
        AppDelegate.token = InstanceID.instanceID().token()
           //let router = UserRouter(endpoint: .updatePushToken(token: token, userId: <#T##String#>))
//        UserManager.sharedInstance.registerPushToken(token, completion: { success, error in
//            guard success && error == nil else {
//                debugPrint("Error: \(String(describing: error))")
//                return
//            }
//        })
    }

    // MARK: - Navigation
    
    func navigateToApplication() {
        debugPrint("Navigating to application")
        DispatchQueue.main.async(execute: {
            let application = UIApplication.shared
            self.registerForPushNotifications(application)
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        })
    }
    
    func navigateToLogin() {
        debugPrint("Navigating to login")
        DispatchQueue.main.async(execute: {
            let nav = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginAndRegisterViewController"))
            
            self.window?.rootViewController = nav
        })
    }


    //MARK: - Updating Push Notification Token -
    fileprivate func updatePushToken() {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            
            AppDelegate.token = result?.token
            
            if let id = UserManager.sharedInstance.user?.id, let token = AppDelegate.token {
                let router = UserRouter(endpoint: .updatePushToken(token: token, userId: "\(id)"))
                UserManager.sharedInstance.performRequest(withRouter: router) { (data) in
                    print("👍", String(describing: type(of: self)),":", #function, " ", data)
                }
            }
        })
    }
    
    func showErr(str: String) {
        let alertController = UIAlertController(title: nil, message: str, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        //self.present(alertController, animated: true, completion: nil)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)

    }
    
}



