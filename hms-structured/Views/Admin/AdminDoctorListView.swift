struct AdminDoctorCardList_Previews: PreviewProvider {
    static var previews: some View {
        AdminDoctorCardList()
    }
}

import SwiftUI
import SDWebImageSwiftUI



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
                Text("Add").font(.title)
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
//                       nurseList
                   }
               }
               .onAppear {
                   doctorsViewModel.fetchDoctors()
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
                
                List {
                            ForEach(doctorsViewModel.doctors, id: \.id) { doctor in
                                Button(action: {
                                    self.selectedDoc = doctor
                                    isDoctorSelected = true
                                }) {
                                    HStack {
                                        if let imageUrl = URL(string: doctor.profileImageURL) {
                                            WebImage(url: imageUrl)
                                                .resizable()
                                                .foregroundColor(.blue)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } else {
                                            Text("Invalid URL")
                                                .foregroundColor(.red)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(doctor.fullName)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            Text(doctor.department)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                        }
                .navigationTitle("\(selectedEntity)")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: AddDoctorView()) {
                            HStack {
                                Text("Add").font(.title)
                                Image(systemName: "plus")
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }
                    }
                }
                
            }
            .onAppear {
                doctorsViewModel.fetchDoctors()
            }
        }
    }
    
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            if let doctorId = doctorsViewModel.doctors[index].id {
                doctorsViewModel.deleteDoctor(doctorId: doctorId)
            } else {
                print("Failed to retrieve doctorId for deletion")
            }
        }
    }
    

        
    }


