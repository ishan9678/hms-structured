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

import SwiftUI

struct RecordsView1: View {
    // Define your segments
    let segments = ["Prescription", "Reports"]
    var patientID : String
    var patientName : String
    // State variable to hold the selected segment
    @State private var selectedSegmentIndex = 0
    @State private var searchText = "" // State variable to hold the search text
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(patientName)'s Records")
                .font(.title)
            
            Picker(selection: $selectedSegmentIndex, label: Text("Select Segment")) {
                ForEach(0..<segments.count) { index in
                    Text(self.segments[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedSegmentIndex == 0 { // Show the prescription list and search bar
                SearchablePrescriptionListView1(patientID: patientID, patientName: patientName, searchText: $searchText)
            } else if selectedSegmentIndex == 1 { // Show ReportsView
                ReportsView( searchText: $searchText)
            }
        }
        .padding()
    }
}


struct SearchablePrescriptionListView1: View {
    let patientID: String
    let patientName: String
    @State private var prescriptions: [Prescription] = []
    @Binding var searchText: String
    @State private var selectedPrescription: Prescription?
    @AppStorage("user_UID") var userUID: String = ""
    @State private var isAddPrescriptionSheetPresented = false
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
                .searchable(text: $searchText)
                .sheet(item: $selectedPrescription) { prescription in
                    PrescriptionView(prescription: prescription)
                }
            }
            
            // Add an overlay button to pop up a sheet for adding a prescription
            NavigationLink(
                destination: PrescriptionForm(patientID: patientID,patientName: patientName).navigationBarBackButtonHidden(),
                isActive: $isAddPrescriptionSheetPresented,
                label: {
                    EmptyView()
                })
                .hidden()
            Button(action: {
                isAddPrescriptionSheetPresented = true
            }) {
                Text("Add Prescription")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
        }
        .onAppear {
            fetchPrescriptions()
        }
    }

    func fetchPrescriptions()  {
           let db = Firestore.firestore()
           let prescriptionsRef = db.collection("prescriptions")

           prescriptionsRef.whereField("patientID", isEqualTo: patientID).getDocuments { querySnapshot, error in
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



struct PrescriptionRow1: View {
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







// Medication model


struct PrescriptionView1: View {
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
