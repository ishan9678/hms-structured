import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Profile: View {
    @State private var heartRate: Int? // Dummy heart rate
    @State private var height: Int? // Dummy height
    @State private var weight: Int? // Dummy weight
    @State private var patient: Patient = Patient(name: "", gender: "", age: 0, bloodGroup: "") // Patient object to hold fetched data
    @State private var isFetchingData: Bool = true // Flag to track data fetching status
    @State private var isChangingPassword: Bool = false
    @State private var confirmPassword: String = ""
    @State private var passwordChangeError: String?
    @State private var newPassword: String = ""
    @State private var isRecordsViewActive = false

    var body: some View {
        ScrollView {
            VStack(spacing: 70) {
                Text("My Account")
                    .font(.system(size: 30))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.bgColor1)
                        .frame(width: 350, height: 200)
                    HStack(spacing: 50) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        VStack(alignment: .center, spacing: 5) {
                            Text("\(patient.name)")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .padding(.top, 30)
                            Text("\(patient.gender)")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            Text("\(patient.bloodGroup)")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                }
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 320, height: 300)
                    .foregroundColor(.white)
                    .overlay(
                        VStack {
                            Divider()
                            HStack {
                                Image(systemName: "list.clipboard")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.bgColor1)
                                Text("Your Records")
                                    .foregroundColor(.bgColor1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.bgColor1)
                            }
                            .padding()
                            .onTapGesture {
                                isRecordsViewActive = true
                            }
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
                                        .foregroundColor(.bgColor1)
                                    Text("Log Out")
                                        .foregroundColor(.bgColor1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.bgColor1)
                                }
                                .padding()
                            }
                        }
                        .padding(.top, -150)
                    )
            }
        }
        .padding()
        .onAppear {
            fetchPatientProfile()
        }
        .sheet(isPresented: $isRecordsViewActive) {
            RecordsView()
        }
    }
    
    func fetchPatientProfile() {
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("patients").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching patient profile: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                do {
                    let patient = try document.data(as: Patient.self)
                    self.patient = patient
                } catch {
                    print("Error decoding patient profile: \(error.localizedDescription)")
                }
            } else {
                print("Patient profile document does not exist")
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

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}

