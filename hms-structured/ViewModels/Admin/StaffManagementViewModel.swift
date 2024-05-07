//
//  StaffManagementViewModel.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct StaffMember: Identifiable {
    var id: String // Typically the Firestore document ID
    var profileImageURL: String
    var fullName: String
    var employeeID: String
}

class StaffManagementViewModel: ObservableObject {
    @Published var staffMembers: [StaffMember] = []
    private var db = Firestore.firestore()

    func fetchStaff(entity: String) {
        db.collection(entity).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.staffMembers = []
            } else {
                self.staffMembers = querySnapshot?.documents.map { document in
                    return StaffMember(
                        id: document.documentID,
                        profileImageURL: document.data()["profileImageURL"] as? String ?? "",
                        fullName: document.data()["fullName"] as? String ?? "N/A",
                        employeeID: document.data()["employeeID"] as? String ?? "N/A"
                    )
                } ?? []
            }
        }
    }
}
