import SwiftUI
import FirebaseFirestore
import FirebaseMessaging

// Define your EmergencyCode struct as before
struct EmergencyCode {
    let code: String
    let description: String
    let color: Color
    let hexCode: String
}

struct EmergencyView: View {
    let staticDocumentID = "emergencyNotification"
    
    let emergencyCodes = [  EmergencyCode(code: "Blue", description: "Medical Emergency", color: .blue, hexCode: "#0000FF"),
                            EmergencyCode(code: "Red", description: "Fire", color: .red, hexCode: "#FF0000"),
                            EmergencyCode(code: "Black", description: "Bomb Threat", color: .black, hexCode: "#000000"),
                            EmergencyCode(code: "Gray", description: "Security Alert", color: .gray, hexCode: "#808080"),
                            EmergencyCode(code: "Brown", description: "External Disaster", color: .brown, hexCode: "#A52A2A"),
                            EmergencyCode(code: "Yellow", description: "Missing Person", color: .yellow, hexCode: "#FFFF00"),
                            EmergencyCode(code: "Pink", description: "Infant Abduction", color: .pink, hexCode: "#FFC0CB"),
                            EmergencyCode(code: "Orange", description: "Hazardous Material Spill", color: .orange, hexCode: "#FFA500"),
                            EmergencyCode(code: "Green", description: "Mass Casualty Incident", color: .green, hexCode: "#008000")

        // ... other emergency codes
    ]
    
    @State private var showAlert = false
    @State private var selectedCode: EmergencyCode?
    @State private var selectedDocumentId: String? // To store the ID of the selected document
    
    // Firebase Firestore instance
    let db = Firestore.firestore()
    @State private var emergencyDocExists = false // Flag to check if emergency document exists
    
    var body: some View {
        NavigationView {
            VStack {
                List(emergencyCodes, id: \.code) { code in
                    Button(action: {
                        self.selectedCode = code
                        self.showAlert.toggle()
                    }) {
                        HStack {
                            Image(systemName: "circle.fill").foregroundColor(code.color)
                            VStack(alignment: .leading) {
                                Text(code.code).foregroundColor(code.color).fontWeight(.bold)
                                Text(code.description).foregroundColor(code.color)
                            }
                        }
                        .padding()
                    }
                }
                .navigationBarTitle("Emergency Codes")
                
                if emergencyDocExists {
                    Button(action: {
                        self.endEmergency(documentId: selectedDocumentId ?? "")
                    }) {
                        Text("End Emergency")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            let docRef = db.collection("emergency_notifications").document(staticDocumentID)
            docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let data = document.data(), data["isActive"] as? Bool == true {
                    self.emergencyDocExists = true
                    self.selectedDocumentId = staticDocumentID
                } else {
                    self.emergencyDocExists = false
                    self.selectedDocumentId = nil
                }
            }
        }
        .alert(isPresented: $showAlert) {
            if let code = selectedCode {
                return Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to declare \(code.description)?"),
                    primaryButton: .default(Text("Yes")) {
                        self.sendEmergencyNotification(code: code)
                    },
                    secondaryButton: .cancel()
                )
            } else {
                // Handle ending emergency scenario (if selectedDocumentId has a value)
                return Alert(
                    title: Text("End Emergency"),
                    message: Text("Are you sure you want to end the current emergency?"),
                    primaryButton: .destructive(Text("End Emergency")) {
                        guard let documentId = selectedDocumentId else { return }
                        self.endEmergency(documentId: documentId)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func sendEmergencyNotification(code: EmergencyCode) {
        let notificationPayload = [
            "title": "Emergency Alert",
            "body": "\(code.description)",
            "code": code.code,
            "hexCode": code.hexCode,
            "isActive": true  // Flag to indicate an active emergency
        ] as [String : Any]
        
        // Access the specific emergency_notifications document using the static ID
        let docRef = db.collection("emergency_notifications").document(staticDocumentID)
        
        // Set or update notification data in the specific document
        docRef.setData(notificationPayload) { error in
            if let error = error {
                print("Error updating notification data: \(error.localizedDescription)")
                return
            }
            
            print("Notification data updated successfully!")
            self.selectedDocumentId = staticDocumentID // Use the static document ID
        }
    }

    
    private func endEmergency(documentId: String) {
        let docRef = db.collection("emergency_notifications").document(documentId)
        
        // Update the document to indicate there is no active emergency
        docRef.updateData([
            "isActive": false  // Set isActive to false to indicate no active emergency
        ]) { error in
            if let error = error {
                print("Error clearing emergency notification: \(error.localizedDescription)")
                return
            }
            
            print("Emergency notification cleared successfully!")
        }
    }
    
    private func sendNotificationToDoctors(payload: [String: Any]) {
        // Same as before (FCM notification logic)
    }
}

#if DEBUG
struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
}
#endif

