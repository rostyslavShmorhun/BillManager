// BillManager

import Foundation

struct Bill: Codable {
    let id: UUID
    var amount: Double?
    var dueDate: Date?
    var paidDate: Date?
    var payee: String?
    var remindDate: Date?
    var notificationID: String?
    
    init(id: UUID = UUID()) {
        self.id = id
    }
}

extension Bill: Hashable {
}
