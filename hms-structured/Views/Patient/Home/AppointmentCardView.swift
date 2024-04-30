import SwiftUI
import Firebase
import FirebaseFirestore

struct AppointmentCard: View {
    let appointment: Appointments
    

    var body: some View {
        HStack(spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack{
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 16/255, green: 22/255, blue: 35/255))
                        .overlay(
                            Text(getDate(date: appointment.bookingDate))
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                        )
                    Spacer()
                     Text(appointment.timeSlot ?? " ")
                            .font(.system(size: 15))
                            
                }
                .padding(.bottom, 10)
                
                
                Text("Doctor: \(appointment.doctorName)")
                    .font(.headline)
                Text("\(appointment.doctorDepartment)")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        
    }
        
    
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
}


struct PatientAppointmentsView: View {
    @State private var fetchedAppointments: [Appointments] = []

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
                    ForEach(Array(fetchedAppointments.enumerated()), id: \.element) { index, appointment in
                        VStack {
                            AppointmentCard(appointment: appointment)
                                .frame(width: 230)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .padding([.horizontal,.bottom])
                .padding(.top,0.5)
            }
        }
        .onAppear {
            Task {
                do {
                    try await fetchAppointments()
//                    print("fetchedappointments",fetchedAppointments)

                } catch {
                    print(error)
                }
            }
        }
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
                        let appointment = Appointments(bookingDate: bookingDate, timeSlot: appointmentData["timeSlot"] as? String, doctorID: appointmentData["doctorID"] as? String ?? "", doctorName: appointmentData["doctorName"] as? String ?? "", doctorDepartment: appointmentData["doctorDepartment"] as? String ?? "", patientName: appointmentData["patientName"] as? String ?? "", patientID: appointmentData["patientID"] as? String ?? "")
                        fetchedAppointments.append(appointment)
                    }
                }
            }

            // Sort appointments by bookingDate in ascending order
            fetchedAppointments.sort { $0.bookingDate < $1.bookingDate }

        } catch {
            print("Error fetching document: \(error)")
        }
    }
}





//struct PatientAppointmentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientAppointmentsView(appointments: appointments)
//    }
//}



