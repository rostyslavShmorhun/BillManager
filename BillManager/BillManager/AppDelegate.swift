//
//  AppDelegate.swift
//  BillManager
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let notificationCenter =  UNUserNotificationCenter.current()
        
        let remaindAction = UNNotificationAction(identifier: Bill.snoozeAlerm, title: "Remid in a 1 hour", options: [] )
        let billPaid =  UNNotificationAction(identifier: Bill.snoozeAlerm, title: "Mark a bill as paid", options: [.authenticationRequired] )
        
        let billCategor = UNNotificationCategory(identifier: Bill.notificationCategoryID, actions: [remaindAction, billPaid], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([billCategor])
        notificationCenter.delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationID = response.notification.request.identifier
        guard var bill = Database.shared.getBill(notificationID: notificationID) else { completionHandler(); return }
        
        switch response.actionIdentifier {
        case "Remind":
            let remindDate = Date().addingTimeInterval(60 * 60)

            bill.schedule(date: remindDate) { (updatedBill) in
                Database.shared.updateAndSave(updatedBill)
            }
        case "MarkBillPaid":
            bill.paidDate = Date()
            Database.shared.updateAndSave(bill)
        default:
            break
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {}

