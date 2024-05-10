import SwiftUI
import SDWebImageSwiftUI
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
    @AppStorage("log_status") var logStatus:Bool = false
    @AppStorage("role") var role:String = ""
    var body: some View {

//        VStack {
            VStack(spacing:30) {
                    
                    Text("My Account")
                    .font(.system(size: 30))
                ZStack{
                    Rectangle()
                        .fill(.bgColor1)
                        .cornerRadius(10)
                        .frame(width: 350,height: 200)
                    HStack{
                        let doctor = doctor
                        if let imageUrl = URL(string: doctor.profileImageURL) {
                            WebImage(url: imageUrl)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                                .padding()
                                        }
                        VStack{
                            Text(doctor.fullName ?? "Doctor Name")
                                .foregroundColor(.white)
                                .font(.system(size: 21))
                                .fontWeight(.bold)
//                                .padding(.top,10)
                            Text(doctor.department)
                                .foregroundColor(.white)
                            
                        }

                                        
                                    
        //                                ProgressView()
        //                                    .progressViewStyle(CircularProgressViewStyle())
                                    
                                }
                }
//                        .padding(.top,-60)
                    
                    RoundedRectangle(cornerRadius: 20)
                    .frame(width: 320,height: 450)
                        .foregroundColor(.white)
                        .overlay(
                            VStack {
                                Divider()
                                NavigationLink(destination: UpdateView(doctor: doctor)) {
                                    HStack {
                                        Image("settings")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.bgColor1)
                                        Text("Account Settings")
                                            .foregroundColor(.bgColor1)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.bgColor1)
                                    }
                                }
                                .padding()
                                
                                Divider()
                                
                                HStack {
                                    Image("padlock")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.bgColor1)
                                    Text("Change Password")
                                        .foregroundColor(.bgColor1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.bgColor1)
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
                                                .foregroundColor(.blue)
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
                                        logStatus = false
                                        role = ""
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
                                            .foregroundColor(.bgColor1)
                                        Text("Log Out")
                                            .foregroundColor(.bgColor1)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.bgColor1)
                                    }
                                    .padding()
                                }
                            }.padding(.top,-150)
                        )
                }
            .padding()
            .onAppear {
                fetchDoctorProfile()
        }
//        }
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
