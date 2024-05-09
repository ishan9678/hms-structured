import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine

struct DoctorDetailsView: View {
    var doctor: Doctor
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var currentMonth = ""
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @ObservedObject var indexDate = bookingCal
    @State private var showAlert = false
    @State private var fetchedAppointments: [Appointments] = []
    @State private var availabilityCounts: [String: Int] = [
            "9:00 - 11:00": 0,
            "11:00 - 12:00": 0,
            "12:00 - 2:00": 0,
            "2:00 - 4:00": 0
    ]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                
                if let imageUrl = URL(string: doctor.profileImageURL) {
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
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
                HStack{
                    
                    Text("Book your appointment")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.bottom, 25)
                
                
                DateCalendarView(selectedDate: $selectedDate)
                    .padding(.bottom, 10)
                
                
                // Morning set
                Text("Time Slots")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                
                VStack {
                    HStack(spacing: 20) {
                        // Time slots for morning set
                        TimeSlotView(time: "9:00 - 11:00", isSelected: selectedTime == "9:00 - 11:00", availabilityCount: availabilityCounts["9:00 - 11:00", default: 0]) { time in
                            selectedTime = time
                        }
                        TimeSlotView(time: "11:00 - 12:00", isSelected: selectedTime == "11:00 - 12:00", availabilityCount: availabilityCounts["11:00 - 12:00", default: 0]) { time in
                            selectedTime = time
                        }
                        
                    }
                    .padding()
                    HStack(spacing: 20) {
                        // Time slots for morning set
                        TimeSlotView(time: "12:00 - 2:00", isSelected: selectedTime == "12:00 - 2:00", availabilityCount: availabilityCounts["12:00 - 2:00", default: 0]) { time in
                            selectedTime = time
                        }
                        TimeSlotView(time: "2:00 - 4:00", isSelected: selectedTime == "2:00 - 4:00", availabilityCount: availabilityCounts["2:00 - 4:00", default: 0]) { time in
                            selectedTime = time
                        }
                        
                    }
                }
                .padding(.bottom, 20)
          

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
                        .cornerRadius(15)
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
            checkTimeSlotAvailability(doctor: doctor, selectedDate: selectedDate) { timeSlotAvailability in
                print(timeSlotAvailability.slotCounts)
                availabilityCounts["9:00 - 11:00"] = timeSlotAvailability.slotCounts["9:00 - 11:00"]
                availabilityCounts["11:00 - 12:00"] = timeSlotAvailability.slotCounts["11:00 - 12:00"]
                availabilityCounts["12:00 - 2:00"] = timeSlotAvailability.slotCounts["12:00 - 2:00"]
                availabilityCounts["2:00 - 4:00"] = timeSlotAvailability.slotCounts["2:00 - 4:00"]
            }
        }
        .onReceive(Just(selectedDate)) { _ in
                checkTimeSlotAvailability(doctor: doctor, selectedDate: selectedDate) {
                    timeSlotAvailability in
                    print(timeSlotAvailability.slotCounts)
                    print("Selected date change", selectedDate)
                    availabilityCounts["9:00 - 11:00"] = timeSlotAvailability.slotCounts["9:00 - 11:00"]
                    availabilityCounts["11:00 - 12:00"] = timeSlotAvailability.slotCounts["11:00 - 12:00"]
                    availabilityCounts["12:00 - 2:00"] = timeSlotAvailability.slotCounts["12:00 - 2:00"]
                    availabilityCounts["2:00 - 4:00"] = timeSlotAvailability.slotCounts["2:00 - 4:00"]
                }
        }
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
        
        func checkTimeSlotAvailability(doctor: Doctor, selectedDate: Date, completion: @escaping (TimeSlotAvailability) -> Void){
            let db = Firestore.firestore()
            
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not logged in")
                return
            }
            
            print("date", selectedDate)
            
            var timeSlotAvailability = TimeSlotAvailability()
            
            db.collection("appointments").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting appointments: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No appointments found")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    
                    for (_, appointmentData) in data {
                        if let appointmentData = appointmentData as? [String: Any] {
                            
                            
                            if let doctorID = appointmentData["doctorID"] as? String, doctorID == doctor.id {
                                
                                if let bookingDateTimestamp = appointmentData["bookingDate"] as? Timestamp {
                                    let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                                    
                                    // Compare the bookingDate with the selectedDate
                                    if Calendar.current.isDate(bookingDate, inSameDayAs: selectedDate) {
                                        if let timeSlot = appointmentData["timeSlot"] as? String {
                                            if var count = timeSlotAvailability.slotCounts[timeSlot] {
                                                count += 1
                                                timeSlotAvailability.slotCounts[timeSlot] = count
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                completion(timeSlotAvailability)
            }
        }
    }

struct TimeSlotAvailability {
     var slotCounts: [String: Int] = [
         "9:00 - 11:00": 0,
         "11:00 - 12:00": 0,
         "12:00 - 2:00": 0,
         "2:00 - 4:00": 0
     ]
 }
 
    
    // Preview
    struct DoctorDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            let doctor = Doctor(id: "1", fullName: "Dr. John Doe", gender: "Male", dateOfBirth: Date(), email: "john.doe@example.com", phone: "1234567890", emergencyContact: "9876543210", profileImageURL: "", employeeID: "EMP001", department: "Cardiology", qualification: "MBBS", position: "Cardiologist", startDate: Date(), licenseNumber: "LIC001", issuingOrganization: "Medical Board", expiryDate: Date(), description: "Lorem ipsum dolor sit amet", yearsOfExperience: "5")
            return DoctorDetailsView(doctor: doctor)
                .previewLayout(.sizeThatFits)
        }
    }
    
