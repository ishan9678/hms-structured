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
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.blue)
                    .frame(width: 400, height: 400)
                    .overlay(
                        HStack {
                            if let heartRate = heartRate {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                Text("Heart rate")
                                    .foregroundColor(.white)
                                Text("\(heartRate) bpm")
                                    .foregroundColor(.white)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            
                            if let height = height {
                                Image("height")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                Text("Height")
                                    .foregroundColor(.white)
                                Text("\(height) cm")
                                    .foregroundColor(.white)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            
                            if let weight = weight {
                                Image("weight")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                Text("Weight")
                                    .foregroundColor(.white)
                                Text("\(weight) kg")
                                    .foregroundColor(.white)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        }
                    )
                    .padding(.top,-60)
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .padding(.top,350)
                    .overlay(
                        VStack {
                                HStack {
                                    Image("padlock")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("Change Password")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            
                            .padding()
                            
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
            fetchPatientProfile()
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
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
        }
    }


