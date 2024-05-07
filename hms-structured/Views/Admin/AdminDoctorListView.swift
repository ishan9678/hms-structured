

struct AdminDoctorCardList_Previews: PreviewProvider {
    static var previews: some View {
        DoctorCardList()
    }
}

import SwiftUI



struct AdminDoctorCardList: View {
    @ObservedObject var doctorsViewModel = AddDoctorsViewModel()
    @ObservedObject var nurseViewModel = AddNursesViewModel()
    
    @State private var selectedNurse : Nurse = Nurse(profileImageURL: "", fullName: "", gender: "", dateOfBirth: Date(), email: "", phone: "", emergencyContact: "" , employeeID: "", department: "" , position: "", startDate: Date(), description: "", yearsOfExperience: "")
    
    @State private var selectedDoc : Doctor = Doctor(fullName: "", gender: "", dateOfBirth: Date(), email: "", phone: "", emergencyContact: "", profileImageURL: "", employeeID: "", department: "", qualification: "", position: "", startDate: Date(), licenseNumber: "", issuingOrganization: "", expiryDate: Date(), description: "", yearsOfExperience: "")
    @State private var isDoctorSelected = false
    @State private var isNurseSelected = false
    @State private var selectedEntity = "Doctors"
    let entities = [ "Doctors", "Nurses"]
    @State private var showAddView = false
    
    
    var addButton: some View {
        Button(action: {
            showAddView = true
        }) {
            HStack {
                Text("Add")
                Image(systemName: "plus")
            }
            .padding()
            .foregroundColor(.blue)

        }
    }
    
    var body: some View {
           NavigationView {
               VStack {
                   // Segmented Picker
                   
                   
                   // List based on selected entity
                   if selectedEntity == "Doctors" {
                       doctorList
                   } else if selectedEntity == "Nurses" {
                       nurseList
                   }
               }
               .onAppear {
                   doctorsViewModel.fetchDoctors()
               }
           }
       }
    
    

    
    var nurseList: some View {
        NavigationView {
            VStack {
                
                
                List(nurseViewModel.nurses, id: \.id) { nurse in
                    Button(action: {
                        self.selectedNurse = nurse
                        isNurseSelected = true
                        print("\(selectedNurse.fullName)")
                    }) {
                        HStack{
                                                            Image(systemName: "person.fill")
                   
                                                                .resizable()
                                                                .foregroundColor(.blue)
                                                                .frame(width: 50, height: 50)
                                                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(nurse.fullName)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Text(nurse.department)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .foregroundColor(.white)
                            
                            
                        }
                        
                    }
                    
                }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            addButton
                        }
                    }
                    .sheet(isPresented: $showAddView) {
                        if selectedEntity == "Doctors" {
                            AddDoctorView()
                        } else if selectedEntity == "Nurses" {
                            AddNurseView()
                        } else {
                            Text("Add Patient View goes here") // Placeholder for AddPatientView
                        }
                    }
            }
            .onAppear {
                nurseViewModel.fetchNurse()
            }
        }
    }
    
    var doctorList: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: UpdateView(doctor: selectedDoc) ,
                    isActive: $isDoctorSelected
                ) {
                    EmptyView()
                }
                
                List(doctorsViewModel.doctors, id: \.id) { doctor in
                    Button(action: {
                        self.selectedDoc = doctor
                        isDoctorSelected = true
                        print("\(selectedDoc.fullName)")
                    }) {
                        HStack{
                                                            Image(systemName: "person.fill")
                   
                                                                .resizable()
                                                                .foregroundColor(.blue)
                                                                .frame(width: 50, height: 50)
                                                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(doctor.fullName)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Text(doctor.department)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .foregroundColor(.white)
                            
                            
                        }
                        
                    }
                    
                }
                .navigationTitle("\(selectedEntity)")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton
                    }
                }
                .sheet(isPresented: $showAddView) {
                    if selectedEntity == "Doctors" {
                        AddDoctorView()
                    } else if selectedEntity == "Nurses" {
                        AddNurseView()
                    } else {
                        Text("Add Patient View goes here") // Placeholder for AddPatientView
                    }
                }
            }
            .onAppear {
                doctorsViewModel.fetchDoctors()
            }
        }
    }
    
    
    

        
    }
    

