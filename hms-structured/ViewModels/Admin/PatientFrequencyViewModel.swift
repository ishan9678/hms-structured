//
//  PatientFrequencyViewModel.swift
//  hms-structured
//
//  Created by Divyanshu Pabia on 09/05/24.
//

import Foundation
import Firebase
import FirebaseFirestore

import FirebaseFirestore
import FirebaseFirestoreSwift

class PatientFrequencyViewModel: ObservableObject {
    @Published var patientFrequency: [String: Int] = ["Sunday": 0, "Monday": 0, "Tuesday": 0, "Wednesday": 0, "Thursday": 0, "Friday": 0, "Saturday": 0]
    @Published var totalPatients: Int = 0
    @Published var totalDoctors: Int = 0
    @Published var totalAppointments: Int = 0


    private var db = Firestore.firestore()

    func fetchBookings() {
        db.collection("appointments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            for document in querySnapshot!.documents {
                let bookings = document.data()
                
                for (_, bookingData) in bookings {
                    if let bookingData = bookingData as? [String: Any],
                       let bookingDateTimestamp = bookingData["bookingDate"] as? Timestamp {
                        
                        let bookingDate = bookingDateTimestamp.dateValue()
                        let weekday = Calendar.current.component(.weekday, from: bookingDate)
                        let weekdayName = DateFormatter().weekdaySymbols[weekday - 1] // Adjusting for zero-based index
                        
                        self.patientFrequency[weekdayName, default: 0] += 1
                    }
                }
            }
            
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
                print("Weekly Booking Frequencies: \(self.patientFrequency)")
            }
        }
    }
    
    func fetchTotalPatients() {
            db.collection("patients").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching total patients: \(error)")
                } else if let snapshot = querySnapshot {
                    DispatchQueue.main.async {
                        self.totalPatients = snapshot.documents.count  // Update total patients
                    }
                }
            }
        }
    
    func fetchTotalDoctors() {
            db.collection("doctors").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching total doctors: \(error)")
                } else if let snapshot = querySnapshot {
                    DispatchQueue.main.async {
                        self.totalDoctors = snapshot.documents.count  // Update total doctors
                    }
                }
            }
        }
    
    func fetchTotalAppointments() {
            db.collection("appointments").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else if let snapshot = querySnapshot {
                    var totalAppointmentsCount = 0
                    for document in snapshot.documents {
                        let bookings = document.data() // Assuming each document key is a booking ID
                        totalAppointmentsCount += bookings.count // Count each booking in the document
                    }
                    DispatchQueue.main.async {
                        self.totalAppointments = totalAppointmentsCount
                    }
                }
            }
        }
}
