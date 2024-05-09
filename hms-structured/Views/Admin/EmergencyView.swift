import SwiftUI
import FirebaseFirestore
import FirebaseMessaging

// Define your EmergencyCode struct as before
struct EmergencyCode {
    let code: String
    let description: String
    let color: Color
}

struct EmergencyView: View {
    let emergencyCodes = [ EmergencyCode(code: "Blue", description: "Medical Emergency", color: .blue),
                           EmergencyCode(code: "Red", description: "Fire", color: .red),
                           EmergencyCode(code: "Black", description: "Bomb Threat", color: .black),
                           EmergencyCode(code: "Gray", description: "Security Alert", color: .gray),
                           EmergencyCode(code: "Brown", description: "External Disaster", color: .brown),
                           EmergencyCode(code: "Yellow", description: "Missing Person", color: .yellow),
                           EmergencyCode(code: "Pink", description: "Infant Abduction", color: .pink),
                           EmergencyCode(code: "Orange", description: "Hazardous Material Spill", color: .orange),
                           EmergencyCode(code: "Green", description: "Mass Casualty Incident", color: .green)

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
            // Listen for changes in the emergency_notifications collection
            db.collection("emergency_notifications").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Check if there are any documents in the collection
                self.emergencyDocExists = !documents.isEmpty
                
                // Update selectedDocumentId if document exists
                if let doc = documents.first {
                    self.selectedDocumentId = doc.documentID
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
        // Prepare notification payload (same as before)
        let notificationPayload = [
            "title": "Emergency Alert",
            "body": "\(code.description) has been declared.",
            "code": code.code
        ]
        
        // Access the "emergency_notifications" collection in Firestore
        let docRef = db.collection("emergency_notifications").document()
        
        // Add notification data to the collection and store the document ID
        docRef.setData(notificationPayload) { error in
            if let error = error {
                print("Error adding notification data: \(error.localizedDescription)")
                return
            }
            
            print("Notification data saved successfully!")
            self.selectedDocumentId = docRef.documentID // Store the document ID
            
            // Send notification to doctors using FCM (same as before)
            self.sendNotificationToDoctors(payload: notificationPayload)
        }
    }
    
    private func endEmergency(documentId: String) {
        // Access the document using the stored ID
        let docRef = db.collection("emergency_notifications").document(documentId)
        
        // Delete the document
        docRef.delete() { error in
            if let error = error {
                print("Error deleting emergency notification: \(error.localizedDescription)")
                return
            }
            
            print("Emergency notification ended successfully!")
            self.selectedDocumentId = nil // Clear the document ID
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

