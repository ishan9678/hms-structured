//
//  StaffManagementView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import SwiftUI

import SwiftUI

struct StaffManagementView: View {
    @State private var selectedEntity = "Doctors"
    let entities = ["Patients", "Doctors", "Nurses"]
    @State private var showAddView = false
    @ObservedObject var viewModel = StaffManagementViewModel()


    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Entity", selection: $selectedEntity) {
                    ForEach(entities, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedEntity) { newValue in
                                    viewModel.fetchStaff(entity: newValue.lowercased())
                                }

                List(viewModel.staffMembers) { member in
                                    StaffMemberComponent(member: member)
                                }
                .navigationTitle("\(selectedEntity)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }

    var addButton: some View {
        Button(action: {
            showAddView = true
        }) {
            Label("Add", systemImage: "plus")
        }
    }

    func deleteItem(at offsets: IndexSet) {
        // Implement deletion logic
    }
}

struct StaffMemberComponent: View {
    var member: StaffMember
    
    

    var body: some View {
        
            
            
            HStack {
                if let url = URL(string: member.profileImageURL), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading) {
                    Text(member.fullName)
                    Text("ID: \(member.employeeID)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            
        
        
       
        
        
    }
}



#Preview {
    StaffManagementView()
}
