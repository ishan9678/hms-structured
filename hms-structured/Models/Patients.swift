//
//  Patients.swift
//  hms
//
//  Created by srijan mishra on 25/04/24.
//

import Foundation
import FirebaseFirestoreSwift
struct Patient: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var gender: String
    var age: Int
    var bloodGroup: String
}

