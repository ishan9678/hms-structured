import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct DProfile: View {
    @State private var appointmentsSchedule: Int? = 10 // Dummy number of appointments
    @State private var hours: Int? = 5 // Dummy number of hours
    @State private var doctor: Doctor = Doctor(fullName: "", gender: "", dateOfBirth: Date(), email: "", phone: "", emergencyContact: "", profileImageURL: "", employeeID: "", department: "", qualification: "", position: "", startDate: Date(), licenseNumber: "", issuingOrganization: "", expiryDate: Date(), description: "", yearsOfExperience: "")// Doctor object to hold fetched data
    @State private var isFetchingData: Bool = true // Flag to track data fetching status
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isChangingPassword: Bool = false
    @State private var passwordChangeError: String?
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.bgColor1)
                    .frame(width: 400, height: 400)
                    .overlay(
                        VStack {
                            
                             let doctor = doctor
                                if !doctor.profileImageURL.isEmpty,
                                   let url = URL(string: doctor.profileImageURL),
                                   let imageData = try? Data(contentsOf: url),
                                   let uiImage = UIImage(data: imageData) {

                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .padding(.top, 80)
                                        .padding(.bottom, 0)
                                } else {
                                    Text("No Profile Image")
                                }
                                Text(doctor.fullName ?? "Doctor Name")
                                    .foregroundColor(.white)
                                    .padding(.top,10)
                                    .font(.headline)
                                
                            
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle())
                            
                        }
                    )
                    .padding(.top,-60)
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .padding(.top,350)
                    .overlay(
                        VStack {
                            Divider()
                            NavigationLink(destination: UpdateView(doctor: doctor)) {
                                HStack {
                                    Image("settings")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("Account Settings")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .padding()
                            
                            Divider()
                            
                            HStack {
                                Image("padlock")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Change Password")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .onTapGesture {
                                isChangingPassword.toggle()
                            }
                            
                            if isChangingPassword {
                                VStack {
                                    SecureField("New Password", text: $newPassword)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .padding(.bottom, 8)
                                    
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .padding(.bottom, 8)
                                    
                                    if let error = passwordChangeError {
                                        Text(error)
                                            .foregroundColor(.red)
                                            .padding(.bottom, 8)
                                    }
                                    
                                    Button(action: changePassword) {
                                        Text("Change Password")
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                    .padding(.bottom, 8)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Divider()
                            Button(action: {
                                do {
                                    try Auth.auth().signOut()
                                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
                                } catch {
                                    print("Error signing out: \(error.localizedDescription)")
                                }
                            }) {
                                HStack {
                                    Image("info")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("Log Out")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                            }
                        }
                    )
            }
        }
        .padding()
        .onAppear {
            fetchDoctorProfile()
        }
    }
    
    func fetchDoctorProfile() {
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("doctors").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching doctor profile: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                do {
                    let doctor = try document.data(as: Doctor.self)
                    self.doctor = doctor
                } catch {
                    print("Error decoding doctor profile: \(error.localizedDescription)")
                }
            } else {
                print("Doctor profile document does not exist")
            }
            
            isFetchingData = false
        }
    }
    
    func changePassword() {
        guard newPassword == confirmPassword else {
            passwordChangeError = "Passwords do not match"
            return
        }
        
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                passwordChangeError = error.localizedDescription
            } else {
                isChangingPassword = false
                newPassword = ""
                confirmPassword = ""
                passwordChangeError = nil
            }
        }
    }
}

struct DProfile_Previews: PreviewProvider {
    static var previews: some View {
        DProfile()
    }
}
