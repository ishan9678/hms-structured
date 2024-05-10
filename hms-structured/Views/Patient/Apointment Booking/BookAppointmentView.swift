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
import FirebaseFirestore
import GoogleGenerativeAI
import SDWebImageSwiftUI

let config = GenerationConfig(
  temperature: 1,
  topP: 0.95,
  topK: 0,
  maxOutputTokens: 8192
)

struct BookAppointmentView: View {
    @State private var categories: [String] = []
    @State private var selectedDate = Date()
    @StateObject var weekStore = WeekStore()
    @State private var selectedTime: String? = nil
    @State private var currentMonth = ""
    @State private var departmentName: String = ""
    @State private var searchQuery: String = ""
    @State private var showAllCategories = false
    @State private var selectedBookingType = 0
    @State private var medicalTestCategories: [String] = medicalTests.keys.map { $0 }

    

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    
                    Section() {
                        ZStack(alignment: .trailing) {
                            TextField("Symptoms, diseases", text: $searchQuery)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .frame(width: 360)
                                .padding(.leading, 240)
                            
                            if !searchQuery.isEmpty {
                                Button(action: {
                                    searchDepartment(for: searchQuery)
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    }

                    Spacer()
                    
                    Picker(selection: $selectedBookingType, label: Text("")) {
                        Text("Book Appointment").tag(0)
                        Text("Book Medical Test").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 400)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)


                    Section() {
                        
                        if(selectedBookingType == 0){
                            
                            ForEach(categories, id: \.self) { category in
                                VStack {
                                    NavigationLink(destination: DoctorListView(category: category)){
                                        Image(category)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .padding()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                                    }
                                    
                                    NavigationLink(destination: DoctorListView(category: category)) {
                                        Text(category)
                                            .foregroundColor(.black)
                                            .padding(.bottom, category.contains(" ") ? 0 : 22)
                                    }
                                }
                            }
                        } else{
                            ForEach(medicalTestCategories, id: \.self) { category in
                                VStack {
                                    NavigationLink(destination: MedicineTestListView(category: category)){
                                        Image(category)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .padding()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                                    }
                                    NavigationLink(destination: MedicineTestListView(category: category)){
                                        Text(category)
                                            .foregroundColor(.black)
                                            .padding(.bottom, category.contains(" ") ? 0 : 22)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                        
                        
                        if showAllCategories {
                            Button("Show All Categories") {
                                departmentName = ""
                                fetchCategories()
                                showAllCategories = false
                            }
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(selectedBookingType == 0 ? "Book Appointment" : "Book Medical Test")
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
                        
            if !departmentName.isEmpty {
                self.categories = [departmentName]
                print("categories", self.categories)
            }
        }
    }

    private func searchDepartment(for query: String) {
        let model = GenerativeModel(
            name: "gemini-1.5-pro-latest",
            apiKey: "AIzaSyBV6mcL_K-UGuP-jI2X8yier815VjMbFx4",
            generationConfig: config,
            safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone),
                SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
            ]
        )
        print("Function called")
        
        print(query)
        
        Task {
            do {
                let prompt = "Given the departments of the hospital which are Emergency Medicine, General Physician, Cardiology, Obstetrics & Gynecology, Pediatrics, Oncology, Neurology, Orthopedics, Radiology. The given input would be symptoms or diseases and you need to respond with the department name that would be responsible, if its something minor return with General Physician. Here is the input: "
                let response = try await model.generateContent(prompt + query)
                print(response)
                let departmentName = response.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.departmentName = departmentName
                print("Department Name: \(departmentName)")
                fetchCategories()
                showAllCategories = true
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}

struct DoctorListView: View {
    var category: String
    @ObservedObject var doctorsViewModel = DoctorsViewModel()
    @State private var selectedDoc : Doctor = Doctor(fullName: "", gender: "", dateOfBirth: Date(), email: "", phone: "", emergencyContact: "", profileImageURL: "", employeeID: "" , department: "", qualification: "", position: "", startDate: Date(), licenseNumber: "", issuingOrganization: "", expiryDate: Date(), description: "", yearsOfExperience: "")
    @State private var isDoctorSelected = false
    
    var body: some View {
        VStack{
            NavigationView {
                VStack {
                    NavigationLink(
                        destination: DoctorDetailsView(doctor: selectedDoc),
                        isActive: $isDoctorSelected
                    ) {
                        EmptyView()
                    }
                    
                    List(doctorsViewModel.doctors.filter { $0.department == category }, id: \.id) { doctor in
                        Button(action: {
                            self.selectedDoc = doctor
                            isDoctorSelected = true
                            print("\(selectedDoc.fullName)")
                        }) {
                            HStack{
                                if let imageUrl = URL(string: doctor.profileImageURL) {
                                    WebImage(url: imageUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
                                } else {
                                    // Handle invalid URL
                                    Text("Invalid URL")
                                        .foregroundColor(.red)
                                }
                                
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
                    }
                }
                .onAppear {
                    fetchDoctors()
                }
            }
            .navigationTitle(isDoctorSelected ? "" : category + " Doctors")
            .navigationBarBackButtonHidden(isDoctorSelected ? true : false)
        }
    }
    
    private func fetchDoctors() {
        doctorsViewModel.fetchDoctors()
    }
}

struct MedicineTestListView: View {
    var category: String
    @State private var selectedTest: String?
    @State private var isDetailViewActive = false
    
    var body: some View {
        VStack {
            NavigationView {
                List(medicalTests[category] ?? [], id: \.self) { medicalTest in
                    Button(action: {
                        self.selectedTest = medicalTest
                        self.isDetailViewActive = true
                    }) {
                        HStack {
                            Image(category)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .padding()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                            
                            Text(medicalTest)
                                .foregroundColor(.black)
                        }
                    }
                }
                .background(
                    NavigationLink(
                        destination: MedicalTestDetailsView(testName : selectedTest ?? "", category: category),
                        isActive: $isDetailViewActive,
                        label: { EmptyView() }
                    )
                )
            }
            .navigationTitle(isDetailViewActive ? "" : category)
            .navigationBarBackButtonHidden(isDetailViewActive ? true : false)
            .onChange(of: isDetailViewActive) { _ in
                if !isDetailViewActive {
                    self.selectedTest = nil
                }
            }
        }
    }
}

    

