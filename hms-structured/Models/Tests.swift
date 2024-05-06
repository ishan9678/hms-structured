//
//  Tests.swift
//  hms-structured
//
//  Created by Ishan on 07/05/24.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Tests: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var bookingDate: Date
    var timeSlot: String?
    var category: String
    var patientName: String
    var patientID: String
}
