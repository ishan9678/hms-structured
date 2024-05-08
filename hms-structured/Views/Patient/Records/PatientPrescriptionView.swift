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
                   let prescription = Prescription(doctorName: doctorName, doctorSpecialty: doctorSpecialty, symptoms: symptoms, medication: medication, tests: tests, suggestions: suggestions, appointmentDate: appointmentDate ?? Date())
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
            Image(systemName: "person.fill")
                .resizable()
                .clipShape(Circle())
                .frame(width: 50, height: 50)
            
            // Doctor's name and specialization
            VStack(alignment: .leading) {
                Text(prescription.doctorName)
                    .font(.headline)
                Text("Appointment: \(prescription.appointmentDate)")
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
}





import SwiftUI
import FirebaseFirestore


// Prescription model
struct Prescription: Codable, Hashable, Identifiable {
    var id = UUID()
    var doctorName: String
    var doctorSpecialty: String
    var symptoms: String
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
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
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

            // Medication Details
            Section(header: Text("Medication Details")) {
                ForEach(prescription.medication) { medication in
                    VStack(alignment: .leading) {
                        Text("Medication: \(medication.name)")
                        Text("Number of days: \(medication.dosage)")
                        Text("To be taken: \(medication.toBeTaken)")
                        Text("Times of Day: \(medication.selectedTimesOfDay.joined(separator: ", "))")
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
