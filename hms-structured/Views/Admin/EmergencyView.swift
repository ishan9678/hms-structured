import SwiftUI

// Define your EmergencyCode struct as before
struct EmergencyCode {
    let code: String
    let description: String
    let color: Color
}


struct EmergencyView: View {
    let emergencyCodes = [
        EmergencyCode(code: "Blue", description: "Medical Emergency", color: .blue),
        EmergencyCode(code: "Red", description: "Fire", color: .red),
        EmergencyCode(code: "Black", description: "Bomb Threat", color: .black),
        EmergencyCode(code: "Gray", description: "Security Alert", color: .gray),
        EmergencyCode(code: "Brown", description: "External Disaster", color: .brown),
        EmergencyCode(code: "Yellow", description: "Missing Person", color: .yellow),
        EmergencyCode(code: "Pink", description: "Infant Abduction", color: .pink),
        EmergencyCode(code: "Orange", description: "Hazardous Material Spill", color: .orange),
        EmergencyCode(code: "Green", description: "Mass Casualty Incident", color: .green)
    ]
    
    @State private var showAlert = false
    @State private var selectedCode: EmergencyCode?
    
    var body: some View {
        NavigationView {
            List(emergencyCodes, id: \.code) { code in
                Button(action: {
                    self.selectedCode = code
                    self.showAlert.toggle()
                }) {
                    HStack {
                        Image(systemName: "circle.fill").foregroundColor(code.color)
                        VStack(alignment:  .leading){
                            Text(code.code).foregroundColor(code.color).fontWeight(.bold)
                            Text(code.description).foregroundColor(code.color)
                        }
                    }.padding()
                }
            }
            .navigationBarTitle("Emergency Codes")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to declare \(selectedCode?.description ?? "")?"),
                primaryButton: .default(Text("Yes")) {
                    // Add code here to send a notification to all users
                    sendEmergencyNotification(code: selectedCode)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func sendEmergencyNotification(code: EmergencyCode?) {
        // Make a network request to your server to send a notification to all users
        // You can use URLSession or Alamofire for networking
        guard let code = code else { return }
        let notificationPayload = [
            "title": "Emergency Alert",
            "body": "\(code.description) has been declared.",
            "code": code.code
        ]
        
        // Make a POST request to your server with the notification payload
        // Replace "your_server_endpoint" with the actual endpoint URL
        guard let url = URL(string: "your_server_endpoint") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: notificationPayload, options: [])
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle the response from your server
                if let error = error {
                    print("Error sending notification: \(error.localizedDescription)")
                    return
                }
                // Handle success
                print("Notification sent successfully.")
            }
            task.resume()
        } catch {
            print("Error serializing notification payload: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
}
#endif
