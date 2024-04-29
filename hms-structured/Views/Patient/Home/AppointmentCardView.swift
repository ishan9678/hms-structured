import SwiftUI
import Firebase
import FirebaseFirestore

struct AppointmentCard: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack{
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 16/255, green: 22/255, blue: 35/255))
                        .overlay(
                            Text(getDate(date: appointment.date))
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                        )
                    
                     Text(appointment.time, style: .time)
                            .font(.system(size: 20))
                            .padding(.leading, 50)
                }
                .padding(.bottom, 10)
                
                
                Text("Doctor: \(appointment.doctorName)")
                    .font(.headline)
                Text("\(appointment.department)")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .onAppear {
            Task {
                do {
                    try await fetchAppointments()
                } catch {
                    print(error)
                }
            }
        }
    }
        
    
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    func fetchAppointments() async {
        do {
            let db = Firestore.firestore()
            
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not logged in")
                return
            }
            
            let document = try await db.collection("appointments").document(userId).getDocument()
            guard let data = document.data() else {
                print("Document does not exist or data is nil")
                return
            }

            for (_, appointmentData) in data {
                if let appointmentData = appointmentData as? [String: Any] {
                    if let bookingDateTimestamp = appointmentData["bookingDate"] as? Timestamp {
                        let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                        // Now you can use the `bookingDate` in your `Appointments` struct
                        print(bookingDate)
                    }
                }
            }

        } catch {
            print("Error fetching document: \(error)")
        }
    }

}


struct Appointment: Identifiable {
    let id = UUID()
    let date: Date
    let time: Date
    let doctorName: String
    let department: String
}

struct PatientAppointmentsView: View {
    let appointments: [Appointment]

    var body: some View {
        VStack{
            HStack {
                Text("Upcoming appointments")
                    .padding(.leading, 25)
                    .font(.headline)
                Spacer()
                Button("See all") {}
                    .padding(.trailing, 25)
                    .font(.headline)
            }
            .padding(.vertical)
            .background(Color.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(appointments) { appointment in
                        AppointmentCard(appointment: appointment)
                            .frame(width: 230) // Set a fixed width for each card
                    }
                }
                .padding([.horizontal,.bottom])
                .padding(.top,0.5)
            }
        }
    }

}




// Example usage
let appointments: [Appointment] = [
    Appointment(date: Date(), time: Date(), doctorName: "Dr. Smith", department: "Cardiology"),
    Appointment(date: Date(), time: Date(), doctorName: "Dr. Johnson", department: "Neurology"),
    Appointment(date: Date(), time: Date(), doctorName: "Dr. Brown", department: "Orthopedics"),
]

struct PatientAppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientAppointmentsView(appointments: appointments)
    }
}



