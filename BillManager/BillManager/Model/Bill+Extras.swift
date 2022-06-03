//
//  Bill+Extras.swift
//  BillManager
//

import Foundation
import UserNotifications

extension Bill {
    
    static let notificationCategoryID = "AlarmNotification"
    static let snoozeAlerm = "snooze"
    
   
    mutating func removeNotifivation(){
        guard let notificationId = notificationID else {return}
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        notificationID = nil
        remindDate = nil

    }
    
    mutating func schedule(date: Date, completion: @escaping (Bill) -> ()) {
        
        var updatedBill = self
        updatedBill.removeNotifivation()
        
        autohotizeIfNuuded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    completion(updatedBill)
                }
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body =  String(format: "", arguments: [(updatedBill.amount ?? 0).formatted(.currency(code: "usd")), (updatedBill.payee ?? ""), updatedBill.formattedDueDate])
            content.sound = .default
            content.categoryIdentifier = Bill.notificationCategoryID
            
            let triggerDateComponents = Calendar.current.dateComponents([.second,.minute,.hour,.day,.month,.year], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            let notificationID = UUID().uuidString
           let request = UNNotificationRequest(identifier: notificationID , content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        updatedBill.notificationID = notificationID
                        updatedBill.remindDate = date
                    }
                    DispatchQueue.main.async {
                        completion(updatedBill)
                    }
                }
            })
        }
    }
    
    private func autohotizeIfNuuded(completion: @escaping(Bool) -> () ) {
        let natificationCenter = UNUserNotificationCenter.current()
        natificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                natificationCenter.requestAuthorization(options: [.sound]) { granted ,_  in
                    completion(granted)
                }
            case .authorized:
                completion(true)
            case .provisional, .denied, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    
    var hasReminder: Bool {
        return (remindDate != nil)
    }
    
    var isPaid: Bool {
        return (paidDate != nil)
    }
    
    var formattedDueDate: String {
        let dateString: String
        
        if let dueDate = self.dueDate {
            dateString = dueDate.formatted(date: .numeric, time: .omitted)
        } else {
            dateString = ""
        }
        
        return dateString
    }
    
}
