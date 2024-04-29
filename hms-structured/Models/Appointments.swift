//
//  Appointments.swift
//  hms-structured
//
//  Created by Ishan on 26/04/24.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Appointments: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var bookingDate: Date
    var timeSlot: String?
    var doctorID: String
    var doctorName: String
    var doctorDepartment: String
    var patientName: String
    var patientID: String
}
