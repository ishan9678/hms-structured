import SwiftUI
import Firebase
import FirebaseFirestore

struct AppointmentCard: View {
    let appointment: Appointments
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text(getDate(date: appointment.bookingDate))
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .bold()
                        .padding(.vertical, 4)
                        .frame(width: 50, height: 50)
                        .background(Color("bg-color1"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                    Text(appointment.timeSlot ?? " ")
                        .font(.system(size: 15))

                }

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
        .contextMenu {
            Button {
                onDelete()
            } label: {
                Label("Cancel Appointment", systemImage: "trash")
            }
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
    @State private var isLoading = false

    var body: some View {
        VStack{
            HStack {
                Text("Upcoming appointments")
                    .padding(.leading, 25)
                    .font(.headline)
                Spacer()
                Button("May 2024") {}
                    .padding(.trailing, 25)
                    .font(.headline)
            }
            .padding(.vertical, 4)
            .background(Color.white)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 50)
            } else if fetchedAppointments.isEmpty {
                Text("No upcoming appointments")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(fetchedAppointments.enumerated()), id: \.element) { index, appointment in
                            VStack {
                                AppointmentCard(appointment: appointment){
                                    deleteAppointment(appointment: appointment)
                                }
                                .frame(width: 230)
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                    .padding([.horizontal,.bottom])
                    .padding(.top,0.5)
                }
            }
        }
        .onAppear {
            Task {
                isLoading = true
                do {
                    try await fetchAppointments()
                    isLoading = false
                } catch {
                    print(error)
                }
            }
        }
    }

    func fetchAppointments() async {
        do {
            fetchedAppointments = []
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

            for (key , appointmentData) in data {
                if let appointmentData = appointmentData as? [String: Any] {
                    if let bookingDateTimestamp = appointmentData["bookingDate"] as? Timestamp {
                        let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                        let appointment = Appointments(id: key, bookingDate: bookingDate, timeSlot: appointmentData["timeSlot"] as? String, doctorID: appointmentData["doctorID"] as? String ?? "", doctorName: appointmentData["doctorName"] as? String ?? "", doctorDepartment: appointmentData["doctorDepartment"] as? String ?? "", patientName: appointmentData["patientName"] as? String ?? "", patientID: appointmentData["patientID"] as? String ?? "")

                        fetchedAppointments.append(appointment)
                    }
                }
            }

            fetchedAppointments.sort { $0.bookingDate < $1.bookingDate }

        } catch {
            print("Error fetching document: \(error)")
        }
    }

    func deleteAppointment(appointment: Appointments) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid

        let documentRef = db.collection("appointments").document(userId!)

        documentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                print("Document does not exist")
                return
            }

            guard var appointmentsMap = snapshot.data() as? [String: Any] else {
                print("Document data is empty")
                return
            }

            appointmentsMap.removeValue(forKey: appointment.id ?? "")

            documentRef.setData(appointmentsMap) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Appointment successfully deleted")
                    Task{
                        await fetchAppointments()
                    }
                }
            }
        }
    }
}





//struct PatientAppointmentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientAppointmentsView(appointments: appointments)
//    }
//}



