//
//  PatientFrequencyViewModel.swift
//  hms-structured
//
//  Created by Divyanshu Pabia on 09/05/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift

class PatientFrequencyViewModel: ObservableObject {
    @Published var patientFrequency: [String: Int] = ["Sunday": 0, "Monday": 0, "Tuesday": 0, "Wednesday": 0, "Thursday": 0, "Friday": 0, "Saturday": 0]
    @Published var totalPatients: Int = 0
    @Published var totalDoctors: Int = 0
    @Published var totalAppointments: Int = 0
    @Published var totalMedicalTests: Int = 0
    @Published var emergencyColor: Color = .bgColor1



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
    
    func fetchTotalMedicalTests() {
        db.collection("medical-tests").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching medical tests: \(error)")
            } else if let snapshot = querySnapshot {
                var totalTestsCount = 0
                for document in snapshot.documents {
                    let tests  = document.data()
                    totalTestsCount += tests.count
                }
                DispatchQueue.main.async {
                    self.totalMedicalTests = snapshot.documents.count  // Update total medical tests count
                }
            }
        }
    }
    
    func fetchEmergencyColor() {
            let docRef = Firestore.firestore().collection("emergency_notifications").document("emergencyNotification")
            docRef.getDocument { (document, error) in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Document does not exist.")
                    return
                }
                
                if let isActive = document["isActive"] as? Int, isActive != 0 {
                    print("efekfefepije", document["isActive"])
                    
                    guard let hexCode = document.get("hexCode") as? String else {
                        print("Hex code not found or is not a string.")
                        return
                    }

                    print("Fetched Hex Code: \(hexCode)")  // Debug output
                    if self.isValidHexCode(hexCode) {
                        DispatchQueue.main.async {
                            self.emergencyColor = Color(hex: hexCode)
                        }
                    } else {
                        print("Invalid hex code format.")
                    }
                    
                } else {
                    self.emergencyColor = .bgColor1
                    print("falseee")
                    return
                }
                
                
            }
        }

    private func isValidHexCode(_ hex: String) -> Bool {
        let regex = "^#?[0-9a-fA-F]{6}$"  // Updated to allow optional '#' at the start
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: hex)
    }
    }
extension Color {
    init(hex: String) {
        let hexFormatted = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)  // Removes the '#'
        let scanner = Scanner(string: hexFormatted)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b)
        } else {
            self.init(.sRGB, red: 1, green: 0, blue: 0, opacity: 1) // Default to red if parsing fails
        }
    }
}





