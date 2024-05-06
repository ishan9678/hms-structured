//
//  PatientPrescriptionView.swift
//  hms-structured
//
//  Created by SHHH!! private on 03/05/24.
//

import SwiftUI

struct AppointedDoctor: Identifiable, Hashable {
    let id = UUID() // Unique identifier
    let name: String
    let specialization: String
    let appointmentDate: String
    
    // Implement the hash(into:) method
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement the equality operator (==)
    static func ==(lhs: AppointedDoctor, rhs: AppointedDoctor) -> Bool {
        return lhs.id == rhs.id
    }
}



struct SearchablePrescriptionListView: View {
    @Binding var searchText: String
    let doctors: [AppointedDoctor] // Array of Doctor objects
    
    @State private var selectedDoctor: AppointedDoctor? // Store the selected doctor
    
    var body: some View {
        VStack {
            NavigationView{
                List {
                    ForEach(doctors.filter {
                        searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText)
                    }, id: \.self) { doctor in
                        PrescriptionRow(doctor: doctor) {
                            // Set the selected doctor
                            selectedDoctor = doctor
                        }
                    }
                }
                .searchable(text: $searchText)
                // Navigate to PrescriptionView when a doctor is selected
                .sheet(item: $selectedDoctor) { doctor in
                    PrescriptionView(doctor: doctor)
                }
            }
        }
    }
}


struct PrescriptionRow: View {
    let doctor: AppointedDoctor
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
                Text(doctor.name)
                    .font(.headline)
                Text(doctor.specialization)
                    .font(.subheadline)
                Text("Appointment: \(doctor.appointmentDate)")
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


struct PressView: View {
    @State private var searchText = ""
    
    let doctors = [
        AppointedDoctor(name: "Dr. John Doe", specialization: "Cardiologist", appointmentDate: "05/05/2024"),
        AppointedDoctor(name: "Dr. Emily Smith", specialization: "Pediatrician", appointmentDate: "06/05/2024"),
        AppointedDoctor(name: "Dr. Michael Johnson", specialization: "Dermatologist", appointmentDate: "07/05/2024"),
        // Add more doctors as needed
    ]
    
    var body: some View {
        SearchablePrescriptionListView(searchText: $searchText, doctors: doctors)
    }
}

struct PressView_Previews: PreviewProvider {
    static var previews: some View {
        PressView()
    }
}
import SwiftUI
import FirebaseFirestore


// Prescription model
struct Prescription {
    var doctorName: String
    var doctorSpecialty: String
    var symptoms: String
    var medication: [Medication]
    var tests: [TestPress]
    var suggestions: String
}

// Medication model
struct Medication: Identifiable {
    var id = UUID()
    var name: String
    var dosage: Int
    var selectedTimesOfDay: [String]
    var toBeTaken: String
}

// Test model
struct TestPress: Identifiable {
    var id = UUID()
    var name: String
}

struct PrescriptionView: View {
    @State private var prescription: Prescription?
    let doctor: AppointedDoctor
    var body: some View {
        List {
            // Doctor Information
            Section(header: Text("Doctor Information")) {
                if let doctorName = prescription?.doctorName,
                   let doctorSpecialty = prescription?.doctorSpecialty {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text(doctor.name)
                                .font(.headline)
                            Text("Specialty: \(doctor.specialization)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            // Symptoms
            Section(header: Text("Symptoms")) {
                Text(prescription?.symptoms ?? "")
            }
            
            // Medication Details
            Section(header: Text("Medication Details")) {
                ForEach(prescription?.medication ?? []) { medication in
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Medication:")
                                .fontWeight(.bold)
                            Text(medication.name)
                        }
                        HStack{
                            Text("Number of days:")
                                .fontWeight(.bold)
                            Text("\(medication.dosage)")
                        }
                        HStack{
                            Text("To be taken:")
                                .fontWeight(.bold)
                            Text("\(medication.toBeTaken)")
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
                                    .padding(.trailing, 20) // Add spacing between each time of day
                                }
                            }
                        }
                    }
                }
            }
            
            // Test Names
            Section(header: Text("Test Names")) {
                ForEach(prescription?.tests ?? []) { test in
                    Text(test.name)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Prescription")
        .onAppear {
            fetchPrescription()
        }
    }
    
    private func fetchPrescription() {
        let db = Firestore.firestore()
        let prescriptionRef = db.collection("prescriptions").document("GZgZEh06MKCn3h6rCS2d")

        prescriptionRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let doctorName = data?["doctorName"] as? String ?? ""
                let doctorSpecialty = data?["doctorSpecialty"] as? String ?? ""
                let symptoms = data?["symptoms"] as? String ?? ""
                let suggestions = data?["suggestions"] as? String ?? ""
                let medicationData = data?["medicines"] as? [[String: Any]] ?? []
                let medication = medicationData.map { medData -> Medication in
                    let name = medData["name"] as? String ?? ""
                    let dosage = medData["dosage"] as? Int ?? 0
                    let selectedTimesOfDay = medData["selectedTimesOfDay"] as? [String] ?? []
                    let toBeTaken = medData["toBeTaken"] as? String ?? ""
                    return Medication(name: name, dosage: dosage, selectedTimesOfDay: selectedTimesOfDay, toBeTaken: toBeTaken)
                }
                let testData = data?["tests"] as? [[String: Any]] ?? []
                let tests = testData.map { testData -> TestPress in
                    let name = testData["name"] as? String ?? ""
                    return TestPress(name: name)
                }
                
                self.prescription = Prescription(doctorName: doctorName, doctorSpecialty: doctorSpecialty, symptoms: symptoms, medication: medication, tests: tests, suggestions: suggestions)
            } else {
                print("Prescription document does not exist")
            }
        }
    }
}
