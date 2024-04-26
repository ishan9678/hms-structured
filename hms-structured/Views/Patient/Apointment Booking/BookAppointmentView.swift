//
//  BookAppointmentView.swift
//  hms
//
//  Created by Ishan on 23/04/24.
//

struct BookAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        BookAppointmentView()
    }
}

import SwiftUI
import Firebase

struct BookAppointmentView: View {
    @State private var categories: [String] = []

    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Book an appointment")) {
                    TextField("Symptoms, diseases", text: .constant(""))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                Section(header: Text("Categories for doctors")) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: DoctorListView(category: category)) {
                            Text(category)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Book Appointment")
            .onAppear {
                self.fetchCategories()
            }
        }
    }
    
    private func fetchCategories() {
        let db = Firestore.firestore()
        db.collection("doctors").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var uniqueCategories: Set<String> = Set()
            for document in documents {
                if let department = document.data()["department"] as? String {
                    uniqueCategories.insert(department)
                }
            }
            
            self.categories = Array(uniqueCategories).sorted()
        }
    }
}

struct DoctorListView: View {
    var category: String
    @ObservedObject var doctorsViewModel = DoctorsViewModel()
    @State private var selectedDoc : Doctor = Doctor(fullName: "", gender: "", dateOfBirth: Date(), email: "", phone: "", emergencyContact: "", employeeID: "", department: "", qualification: "", position: "", startDate: Date(), licenseNumber: "", issuingOrganization: "", expiryDate: Date(), description: "", yearsOfExperience: "")
    @State private var isDoctorSelected = false
    
    var body: some View {
        List(doctorsViewModel.doctors.filter { $0.department == category }, id: \.id) { doctor in
            Button(action:{
                self.selectedDoc = doctor
                isDoctorSelected = true
                print("\(selectedDoc.fullName)")
            }){
                VStack(alignment: .leading) {
                    Text(doctor.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(doctor.department)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .foregroundColor(.white)
                .padding(.vertical, 5)
            }
            
        }
        .onAppear {
            fetchDoctors()
        }
    }
    
    func fetchDoctors() {
        doctorsViewModel.fetchDoctors()
    }
}


