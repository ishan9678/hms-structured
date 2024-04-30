import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct DoctorDetailsView: View {
    var doctor: Doctor
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var currentMonth = ""
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @ObservedObject var indexDate = bookingCal
    @State private var showAlert = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                
                if let imageUrl = URL(string: doctor.profileImageURL) {
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
                } else {
                    // Handle invalid URL
                    Text("Invalid URL")
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(doctor.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(doctor.department)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
//                        Text(String(format: "%.1f", doctor.rating))
//                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                    
                    Text("Years of Exp: \(doctor.yearsOfExperience)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                .padding(.leading, 10)
                
                
                Spacer()
                
            }
            .padding(.horizontal)
            
            Text("Description:")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading,30)
                
            
            Text(doctor.description)
                .font(.body)
                .padding(.leading,30)

            
           
            // Appointment booking
            VStack {
                Text("Book your appointment")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                
                
                Text(" Choose Day, \(currentMonth)")
                    .padding(.top,2)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                
                
                DateCalendarView(selectedDate: $selectedDate)

                
                // Morning set
                Text("Time Slots")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    // Time slots for morning set
                    TimeSlotView(time: "9:00 - 11:00", isSelected: selectedTime == "9:00 - 11:00") { time in
                        selectedTime = time
                    }
                    TimeSlotView(time: "11:00 - 12:00", isSelected: selectedTime == "11:00 - 12:00") { time in
                        selectedTime = time
                    }
                    
                }
                .padding()
                
               
            
                Button(action: {
                    if let selectedTime = selectedTime {
                        addAppointmentToFirestore(selectedDate: selectedDate, selectedTime: selectedTime, doctor: doctor, userName: userName, userUID: userUID)
                    } else {
                        print("Please select a time slot.")
                    }
                }) {
                    Text("Add Booking")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top)

            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Success"), message: Text("Appointment added successfully"), dismissButton: .default(Text("OK")))
                    }
        }
        .onAppear {
            currentMonth = getCurrentMonth()
        }
    }
    
    func getCurrentMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
    }
    
    func addAppointmentToFirestore(selectedDate: Date, selectedTime: String, doctor: Doctor, userName: String, userUID: String) {
        let appointmentID = UUID().uuidString
        let appointment = Appointments(id: appointmentID,
                                       bookingDate: indexDate.date,
                                       timeSlot: selectedTime,
                                       doctorID: doctor.id ?? "",
                                       doctorName: doctor.fullName, 
                                       doctorDepartment: doctor.department,
                                       patientName: userName,
                                       patientID: userUID)
        
        let appointmentsRef = Firestore.firestore().collection("appointments").document(userUID)
        
//        appointmentsRef.setData([
//            "bookingDate": Timestamp(date: appointment.bookingDate),
//            "timeSlot": appointment.timeSlot,
//            "doctorID": appointment.doctorID,
//            "doctorName": appointment.doctorName,
//            "doctorDepartment": doctor.department,
//            "patientName": appointment.patientName,
//            "patientID": appointment.patientID
//        ]) { error in
//            if let error = error {
//                print("Error adding appointment: \(error.localizedDescription)")
//            } else {
//                print("Appointment added successfully")
//            }
//        }
        let data: [String: Any] = [
            "bookingDate": Timestamp(date: appointment.bookingDate),
            "timeSlot": appointment.timeSlot,
            "doctorID": appointment.doctorID,
            "doctorName": appointment.doctorName,
            "doctorDepartment": doctor.department,
            "patientName": appointment.patientName,
            "patientID": appointment.patientID
        ]

        appointmentsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var appointmentsMap = document.data() ?? [:]
                appointmentsMap[appointmentID] = data

                appointmentsRef.setData(appointmentsMap) { error in
                    if let error = error {
                        print("Error saving drawing: \(error)")
                    } else {
                        print("Drawing saved successfully")
                        showAlert = true
                    }
                }
            } else {
                let appointmentsMap = [appointmentID: data]

                appointmentsRef.setData(appointmentsMap) { error in
                    if let error = error {
                        print("Error saving drawing: \(error)")
                    } else {
                        print("Drawing saved successfully")
                        showAlert = true
                    }
                }
            }
        }
    }
}




// Preview
struct DoctorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let doctor = Doctor(id: "1", fullName: "Dr. John Doe", gender: "Male", dateOfBirth: Date(), email: "john.doe@example.com", phone: "1234567890", emergencyContact: "9876543210", profileImageURL: "", employeeID: "EMP001", department: "Cardiology", qualification: "MBBS", position: "Cardiologist", startDate: Date(), licenseNumber: "LIC001", issuingOrganization: "Medical Board", expiryDate: Date(), description: "Lorem ipsum dolor sit amet", yearsOfExperience: "5")
        return DoctorDetailsView(doctor: doctor)
            .previewLayout(.sizeThatFits)
    }
}

