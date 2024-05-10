//
//  PatientPrescriptionView.swift
//  hms-structured
//
//  Created by SHHH!! private on 03/05/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreInternal



struct SearchablePrescriptionListView: View {
    @State private var prescriptions: [Prescription] = []
    @Binding var searchText: String
    @State private var selectedPrescription: Prescription?
    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(prescriptions.filter {
                        searchText.isEmpty ? true : $0.doctorName.localizedCaseInsensitiveContains(searchText)
                    }, id: \.self) { prescription in
                        PrescriptionRow(prescription: prescription) {
                            selectedPrescription = prescription
                        }
                    }
                }
//                .searchable(text: $searchText)
                .sheet(item: $selectedPrescription) { prescription in
                    PrescriptionView(prescription: prescription)
                }
            }
        }
        .onAppear {
            fetchPrescriptions()
        }
    }

    func fetchPrescriptions()  {
           let db = Firestore.firestore()
           let prescriptionsRef = db.collection("prescriptions")

           prescriptionsRef.whereField("patientID", isEqualTo: userUID).getDocuments { querySnapshot, error in
               if let error = error {
                   print("Error getting prescriptions: \(error.localizedDescription)")
                   return
               }

               guard let documents = querySnapshot?.documents else {
                   print("No prescriptions found")
                   return
               }

               var prescriptions: [Prescription] = []
               for document in documents {
                   let data = document.data()
                   let doctorName = data["doctorName"] as? String ?? ""
                   let doctorSpecialty = data["doctorSpecialty"] as? String ?? ""
                   let symptoms = data["symptoms"] as? String ?? ""
                   let suggestions = data["suggestions"] as? String ?? ""
                   let diagnosis = data["diagnosis"] as? String ?? ""
                   let medicationData = data["medicines"] as? [[String: Any]] ?? []
                   let medication = medicationData.map { medData -> Medication in
                       let name = medData["name"] as? String ?? ""
                       let dosage = medData["dosage"] as? Int ?? 0
                       let selectedTimesOfDay = medData["selectedTimesOfDay"] as? [String] ?? []
                       let toBeTaken = medData["toBeTaken"] as? String ?? ""
                       return Medication(name: name, dosage: dosage, selectedTimesOfDay: selectedTimesOfDay, toBeTaken: toBeTaken)
                   }
                   let testData = data["tests"] as? [[String: Any]] ?? []
                   let tests = testData.map { testData -> TestPress in
                       let name = testData["name"] as? String ?? ""
                       return TestPress(name: name)
                   }
                   let appointmentDate: Date?
                   if let appointmentDateTimestamp = data["appointmentDate"] as? Timestamp {
                       let calendar = Calendar.current
                       let date = Date(timeIntervalSince1970: TimeInterval(appointmentDateTimestamp.seconds))
                       let components = calendar.dateComponents([.year, .month, .day], from: date)
                       appointmentDate = calendar.date(from: components)
                       print("date", appointmentDate)
                   } else {
                       appointmentDate = nil
                   }
                   let prescription = Prescription(doctorName: doctorName, doctorSpecialty: doctorSpecialty, symptoms: symptoms, diagnosis: diagnosis, medication: medication, tests: tests, suggestions: suggestions, appointmentDate: appointmentDate ?? Date())
                   prescriptions.append(prescription)
               }

               // Now you have an array of prescriptions
               self.prescriptions = prescriptions
           }
       }
   }



struct PrescriptionRow: View {
    let prescription: Prescription
    let onTap: () -> Void // Closure to trigger navigation
    
    var body: some View {
        HStack {
            // Doctor's image
            
            
            // Doctor's name and specialization
            VStack(alignment: .leading) {
                Text(prescription.doctorName)
                    .font(.headline)
                Text("Appointment: \(formattedDate(prescription.appointmentDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.vertical, 8)
        // Trigger the onTap closure when the row is tapped
        .onTapGesture {
            onTap()
        }
    }
    private func formattedDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter.string(from: date)
        
    }
}





import SwiftUI
import FirebaseFirestore


// Prescription model
struct Prescription: Codable, Hashable, Identifiable {
    var id = UUID()
    var doctorName: String
    var doctorSpecialty: String
    var symptoms: String
    let diagnosis: String
    var medication: [Medication]
    var tests: [TestPress]
    var suggestions: String
    var appointmentDate: Date
}


// Medication model
struct Medication: Identifiable,Codable, Hashable {
    var id = UUID()
    var name: String
    var dosage: Int
    var selectedTimesOfDay: [String]
    var toBeTaken: String
}

// Test model
struct TestPress: Identifiable,Codable, Hashable {
    var id = UUID()
    var name: String
}

struct PrescriptionView: View {
    let prescription: Prescription

    var body: some View {
        List {
            // Doctor Information
            Section(header: Text("Doctor Information")) {
                HStack {
//                    Image(systemName: "person.circle")
//                        .resizable()
//                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text(prescription.doctorName)
                            .font(.headline)
                        Text("Specialty: \(prescription.doctorSpecialty)")
                            .font(.subheadline)
                    }
                }
            }

            // Symptoms
            Section(header: Text("Symptoms")) {
                Text(prescription.symptoms)
            }
            Section(header: Text("Diagnosis")) {
                Text(prescription.diagnosis)
            }

            // Medication Details
            Section(header: Text("Medication Details")) {
                ForEach(prescription.medication) { medication in
                    VStack(alignment: .leading) {
                                            HStack(spacing:10){
                                                Text("Medication:")
                                                    .fontWeight(.bold)
                                                Text("\(medication.name)")
                                            }
                                            HStack{
                                                Text("Number of days:")
                                                    .fontWeight(.bold)
                                                Text(" \(medication.dosage)")
                                            }
                                            HStack{
                                                Text("To be taken:")
                                                    .fontWeight(.bold)
                                                Text(" \(medication.toBeTaken)")
                                            }
                                            
                                            HStack(alignment:.center,
                                                   spacing:80) {
                                                Text("Times of Day:")
                                                    .padding(.top, 4)
                                                    .fontWeight(.bold)
                                                HStack{
                                                    ForEach(["Morning", "Afternoon", "Night"], id: \.self) { timeOfDay in
                                                        VStack {
                                                            Image(systemName: timeOfDay.lowercased() == "morning" ? "sunrise.fill" : (timeOfDay.lowercased() == "afternoon" ? "sun.max.fill" : "moon.fill"))
                                                                .foregroundColor(timeOfDay.lowercased() == "morning" ? .yellow : (timeOfDay.lowercased() == "afternoon" ? .orange : .blue))
                                                            Text(timeOfDay.prefix(1).capitalized)
                                                            
                                                            // Check if the time of day is present in selectedTimesOfDay
                                                            let isPresent = medication.selectedTimesOfDay.contains(timeOfDay)
                                                            
                                                            // Display indicator (1 if present, 0 if not)
                                                            Text(isPresent ? "1" : "0")
                                                            
                                                            // Display whether it's taken before or after
                                                        }
                                                        .padding(.trailing, 20)
                                                        // Add spacing between each time of day
                                                    }
                                                }
                                            }
                                        }
                }
            }

            // Test Names
            Section(header: Text("Test Names")) {
                ForEach(prescription.tests) { test in
                    Text(test.name)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Prescription")
    }
}
