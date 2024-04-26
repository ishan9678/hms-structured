//
//  DoctorsViewModel.swift
//  HMS-Team 5
//
//  Created by Ishan on 22/04/24.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class DoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []

    private var db = Firestore.firestore()

    func fetchDoctors() {
        db.collection("doctors").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var fetchedDoctors: [Doctor] = []
                for document in querySnapshot!.documents {
                    do {
                         let doctor = try document.data(as: Doctor.self)
                            fetchedDoctors.append(doctor)
                        
                    } catch {
                        print("Error decoding doctor: \(error)")
                    }
                }
                self.doctors = fetchedDoctors
            }
        }
    }
}

