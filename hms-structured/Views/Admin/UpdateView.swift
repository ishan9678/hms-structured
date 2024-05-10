struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        let doctor = Doctor(fullName: "Dr. John Doe", gender: "Male", dateOfBirth: Date(), email: "john.doe@example.com", phone: "1234567890", emergencyContact: "9876543210", profileImageURL: "", employeeID: "EMP001", department: "Cardiology", qualification: "MBBS", position: "Cardiologist", startDate: Date(), licenseNumber: "LIC001", issuingOrganization: "Medical Board", expiryDate: Date(), description: "Lorem ipsum dolor sit amet", yearsOfExperience: "5")
        return UpdateView(doctor: doctor)
            .previewLayout(.sizeThatFits)
    }
}

 

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct UpdateView: View {
    var doctor: Doctor
    //Personal Details
    @State var profilImageeUrl: String = " "
    @State var fullName: String = ""
    @State private var gender = 0
    @State private var dateofbirth = Date()
    @State var emailTextField: String = ""
    @State var phoneTextField: String = ""
    @State var emergencyContactTextField: String = ""
    
    @State var employeeID: String = ""
    @State private var department = 0
    @State var qualification: String = ""
    @State var position: String = ""
    @State var startDate: Date = Date()


    // Professional Licenses
    @State var licenseNumber: String = ""
    @State var issuingOrganization: String = ""
    @State var expiryDate: Date = Date()
    
    @State var loginEmail : String = ""
    @State var loginPwd : String = ""

    // Description
    @State var description: String = ""
    @State var yearsOfExperience: String = ""
    
    @State private var showAlert = false
    

    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var currentMonth = ""
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    let chosenGender = ["Female","Male","Prefer not to disclose"]
    
    let chosenDept = [
        "Emergency Medicine", // Provides immediate care for acute illnesses and injuries.
        "General Physician",    // Handles a wide range of common ailments requiring surgical intervention.
        "Cardiology",         // Manages disorders of the heart and blood vessels.
        "Obstetrics & Gynecology", // Cares for reproductive health, childbirth, and females
        "Pediatrician",         // Focuses on the medical care of infants, children, and adolescents.
        "Oncology",           // Specializes in the diagnosis and treatment of cancer.
        "Neurology",          // Focuses on diseases of the nervous system.
        "Orthopedics",        // Concerned with conditions involving the musculoskeletal system.
        "Radiology",          // Essential for diagnostics using imaging technologies.
        "Internal Medicine"   // Deals with the prevention, diagnosis, and treatment of adult diseases.
    ]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
           
            
            
            Form{
                
                HStack {
//                    AsyncImage(url: URL(string: doctor.profileImageURL)) { image in
//                        image
//                            .resizable()
//                            .frame(width: 130, height: 130)
//                            .cornerRadius(10)
//                            .scaledToFit()
//                    } placeholder: {
////                        ProgressView()
//                    }
                    
                    if let imageUrl = URL(string: doctor.profileImageURL) {
                        WebImage(url: imageUrl)
                            .resizable()
                                                        .frame(width: 130, height: 130)
                                                        .cornerRadius(10)
                                                        .scaledToFit()
                    } else {
                        // Handle invalid URL
                        Text("Invalid URL")
                            .foregroundColor(.red)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(doctor.fullName)
                            .font(.title)
                            .fontWeight(.bold)
        
                        Text(doctor.department)
                            .font(.headline)
            
                        Text("Years of Exp: \(doctor.yearsOfExperience)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                
                
                
                Section(header: Text("Personal Details")) {
                    TextField(doctor.fullName, text: Binding(
                        get: {
                            fullName.isEmpty ? doctor.fullName : fullName
                        },
                        set: {
                            fullName = $0
                        }
                    ))
                    DatePicker("Date of Birth", selection: $dateofbirth, displayedComponents: .date)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(0..<chosenGender.count, id: \.self) { index in
                            Text(self.chosenGender[index]).tag(index)
                        }
                    }
                    
                    HStack {
                        TextField(doctor.email,  text: Binding(
                            get: {
                                emailTextField.isEmpty ? doctor.email : emailTextField
                            },
                            set: {
                                emailTextField = $0
                            }
                        ))
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            Spacer()
                            
                        }
                    
                    HStack {
                            TextField(doctor.phone, text: Binding(
                                get: {
                                    phoneTextField.isEmpty ? doctor.phone : phoneTextField
                                },
                                set: {
                                    phoneTextField = $0
                                }
                            ))
                                .keyboardType(.phonePad)
                            Spacer()
                            
                        }
                    
                    TextField("Emergency Contact",
                              text: Binding(
                                          get: {
                                              emergencyContactTextField.isEmpty ? doctor.emergencyContact : emergencyContactTextField
                                          },
                                          set: {
                                              emergencyContactTextField = $0
                                          }
                                      ))
                }
                
                Section(header: Text("Professional Details")) {
                    TextField(doctor.employeeID, text: Binding(
                        get: {
                            employeeID.isEmpty ? doctor.employeeID : employeeID
                        },
                        set: {
                            employeeID = $0
                        }
                    ))
                    Picker(doctor.department, selection: $department) {
                        ForEach(0..<chosenDept.count, id: \.self) { index in
                            Text(self.chosenDept[index]).tag(index)
                        }
                    }
                    TextField(doctor.qualification, text: Binding(
                        get: {
                            qualification.isEmpty ? doctor.qualification : qualification
                        },
                        set: {
                            qualification = $0
                        }
                    ))
                    TextField(doctor.position, text: Binding(
                        get: {
                            position.isEmpty ? doctor.position : position
                        },
                        set: {
                            position = $0
                        }
                    ))
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }

                Section(header: Text("Professional Licenses")) {
                    TextField(doctor.licenseNumber, text: Binding(
                        get: {
                            licenseNumber.isEmpty ? doctor.licenseNumber : licenseNumber
                        },
                        set: {
                            licenseNumber = $0
                        }
                    ))
                    TextField(doctor.issuingOrganization, text: Binding(
                        get: {
                            issuingOrganization.isEmpty ? doctor.issuingOrganization : issuingOrganization
                        },
                        set: {
                            issuingOrganization = $0
                        }
                    ))
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                }

                Section(header: Text("Details")) {
                    TextField(doctor.description, text: Binding(
                        get: {
                            description.isEmpty ? doctor.description : description
                        },
                        set: {
                            description = $0
                        }
                    ))
                    TextField(doctor.yearsOfExperience, text: Binding(
                        get: {
                            yearsOfExperience.isEmpty ? doctor.yearsOfExperience : yearsOfExperience
                        },
                        set: {
                            yearsOfExperience = $0
                        }
                    ))
                }
            }
            
            Button(action: {
//                showAlert = true
            }) {
                Text("Save")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding()
                    .frame(width: 400, height: 48)
                    
                    .cornerRadius(15)
            }.alert(isPresented: $showAlert) { // Alert configuration
                Alert(
                    title: Text("Confirm Update"),
                    message: Text("Are you sure you want to update these details?"),
                    primaryButton: .default(Text("Confirm")) {
                        
                        let newDoctor = Doctor(fullName: fullName, gender: chosenGender[gender], dateOfBirth: dateofbirth, email: emailTextField, phone: phoneTextField, emergencyContact: emergencyContactTextField, profileImageURL: "", employeeID: employeeID, department: chosenDept[department], qualification: qualification, position: position, startDate: startDate, licenseNumber: licenseNumber, issuingOrganization: issuingOrganization, expiryDate: expiryDate, description: description, yearsOfExperience: yearsOfExperience)
                        //let newDoctor = doctor.toDictionary()

                        let doctorRef = Firestore.firestore().collection("doctors").document()

                        do {
                            try doctorRef.setData(from: newDoctor) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                        } catch {
                            print("Error encodings doctor: \(error)")
                        }

                                 
                    },
                    secondaryButton: .cancel()
                )
            }
            
             

            
        }
        .navigationBarTitle("Doctor Details")
        .onAppear {
             
        }
    }
    
  
    
    
    
    
    // Preview
    
    
   
}
