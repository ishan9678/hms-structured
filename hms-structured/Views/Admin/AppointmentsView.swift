
//
//  AppointmentsView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

//import SwiftUI
//
//struct AppointmentsView: View {
//    var body: some View {
//        Text("Appointments will be shown here.")
//
//    }
//}
//
//#Preview {
//    AppointmentsView()
//}

import SwiftUI
import Firebase

class Bookings: ObservableObject {
    @Published var index: Int = 0
    @Published var date: Date = Date()
}

let bookings: Bookings = Bookings()

struct AppointmentsAdminView: View {
    @State private var hello: String = "Mon"
    @State private var isDropdownExpanded = false
    @State private var selectedDate = Date()
    @State private var appointments: [Appointments] = []
    @State private var fetchedAppointments: [Appointments] = []
    func dateGetter(index: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: index, to: getFirstDayOfWeek(for: selectedDate))!
    }
    
    func getFirstDayOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return startOfWeek
    }
    
    func getDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: date)
    }
    
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    func getMonthAndYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    @ObservedObject var indexDate = booking
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(getMonthAndYear(date: selectedDate))
                        .font(.headline)
                        .foregroundColor(.black)
                    Button(action: {
                        self.isDropdownExpanded.toggle()
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding([.horizontal, .top])
                .cornerRadius(10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<7) { i in
                            let date = dateGetter(index: i)
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {
                                withAnimation {
                                    indexDate.index = i
                                    selectedDate = date
                                    hello = getDay(date: date)
                                }
                                print(date)
                            }) {
                                VStack {
                                    Text((getDay(date: date)))
                                        .font(Font.custom("SF Pro Display Regular", size: 16))
                                        .foregroundColor(isSelected ? .white  : .black )
                                    
                                    Text((getDate(date: date)))
                                        .font(Font.custom("SF Pro Display ", size: 18))
                                        .foregroundColor(isSelected ? .white  : .black)
                                }
                                .frame(alignment: .center)
                                .padding(.leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 64, height: 80)
                                        .foregroundColor(isSelected ? Color("bg-color1") : .white)
                                        .padding(.leading)
                                )
                                .padding()
                            }
                        }
                    }
                    .frame(height: 85)
                    .padding(.bottom)
                    .padding(.trailing, 16)
                }
                
                AppointmentAdminView(temp: hello, appointments: fetchedAppointments,selectedDate: selectedDate)
                Spacer()
            }
            
            if isDropdownExpanded {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.isDropdownExpanded.toggle()
                    }
                
                VStack {
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                }
            }
        }
//        .background(
//            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.60, blue: 0.87), Color(red: 0.56, green: 0.87, blue: 0.97)]), startPoint: .top, endPoint: .bottom)
//        )
        .onAppear {
            self.hello = getDay(date: Date())
            fetchAppointments()
            
        }
    }
    
    
    func fetchAppointments() {
        let db = Firestore.firestore()
        
        db.collection("appointments").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting appointments: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No appointments found")
                return
            }
        
            fetchedAppointments = []
            
            for document in documents {
                let data = document.data()
                
                for (_, appointmentData) in data {
                    if let appointmentData = appointmentData as? [String: Any] {
                        
                        if let bookingDateTimestamp = appointmentData["bookingDate"] as? Timestamp {
                            let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                            // Now you can use the ⁠ bookingDate ⁠ in your ⁠ Appointments ⁠ struct
                            let appointment = Appointments(bookingDate: bookingDate, timeSlot: appointmentData["timeSlot"] as? String, doctorID: appointmentData["doctorID"] as? String ?? "", doctorName: appointmentData["doctorName"] as? String ?? "", doctorDepartment: appointmentData["doctorDepartment"] as? String ?? "", patientName: appointmentData["patientName"] as? String ?? "", patientID: appointmentData["patientID"] as? String ?? "")
                            fetchedAppointments.append(appointment)
//                            print(fetchedAppointments)
                        }
                    }
                }
                
            }
        }
    }
    
//    func fetchAppointments() {
//        let db = Firestore.firestore()
//
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User is not logged in")
//            return
//        }
//
//        print("user id", userId)
//
//        db.collection("appointments").getDocuments { querySnapshot, error in
//            if let error = error {
//                print("Error getting appointments: \(error)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No appointments found")
//                return
//            }
//
//            fetchedAppointments = []
//
//            for document in documents {
//                let data = document.data()
//
//                for (_, appointmentData) in data {
//                    if let appointmentData = appointmentData as? [String: Any] {
//
//                        if let doctorID = appointmentData["doctorID"] as? String, doctorID == userId{
//
//                            if let bookingDateTimestamp = appointmentData["bookingDate"] as? Timestamp {
//                                let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
//                                // Now you can use the ⁠ bookingDate ⁠ in your ⁠ Appointments ⁠ struct
//                                let appointment = Appointments(bookingDate: bookingDate, timeSlot: appointmentData["timeSlot"] as? String, doctorID: appointmentData["doctorID"] as? String ?? "", doctorName: appointmentData["doctorName"] as? String ?? "", doctorDepartment: appointmentData["doctorDepartment"] as? String ?? "", patientName: appointmentData["patientName"] as? String ?? "", patientID: appointmentData["patientID"] as? String ?? "")
//                                fetchedAppointments.append(appointment)
//                                print(fetchedAppointments)
//                            }
//                        }
//                    }
//                }
//
//            }
//        }
//    }
}

struct AdminAppointView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentsAdminView()
    }
}

//struct AppointmentView: View {
//    var temp: String
//    var appointments: [Appointments]
//    var selectedDate: Date
//    var body: some View {
//        VStack {
//            ForEach(Array(appointments.enumerated()), id: \.element) { index,appointment in
//                if retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: appointment.bookingDate){
//                    DisclosureGroup(
//                        content: {
//                            HStack() {
//                                                                VStack(alignment: .leading){
//                                                                    Text("Patients for the Doctor").font(.subheadline).fontWeight(.bold).padding(.bottom,5)
//
//                                                                    Text(appointment.patientName)
//                                                                      .font(Font.custom("SF Pro Display", size: 16).weight(.semibold))
//                                                                      .tracking(0.16)
//                                                                      .lineSpacing(21.60)
//                                                                      .foregroundColor(.black)
//
//
//                                                                }
//                                                                .padding(.leading)
//
//                                                              Spacer()
//                                                                Image(systemName: "arrow.forwardarrow.forward")
//                                                            }
//                                                            .frame(width: 218, height: 84)
//                                                            .background(.white)
//                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                                                            .padding([.horizontal,.vertical],5)
//                                                            .padding(.leading,60)
//                        },
//                        label: {
//                            HStack {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .foregroundColor(Color("bg-color1"))
//                                        .frame(width: 86.78, height: 96)
//                                    Text("\(temp)")
//                                        .font(Font.custom("SF Pro Display", size: 18).weight(.medium))
//                                        .foregroundColor(.white)
//                                }
//                                .frame(width: 86.78, height: 96)
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .foregroundColor(Color("bg-color1"))
//                                        .frame(width: 249.62, height: 96)
//                                    VStack(alignment: .leading) {
//                                        Text("\(appointment.timeSlot!)")
//                                            .font(Font.custom("SF Pro Display", size: 16).weight(.semibold))
//                                            .foregroundColor(.white)
//                                            .padding(.bottom)
//                                        Text("Doctor Name: \(appointment.doctorName)")
//                                            .font(Font.custom("SF Pro Display", size: 14))
//                                            .foregroundColor(.white)
//                                    }
//                                    .offset(x: -30)
//                                }
//                                .frame(width: 249.62, height: 96)
//                            }
//                        }
//                    )
//                    .padding(.horizontal)
//                }
//
//            }
//        }.onAppear(){
//            print("appointments",appointments)
//        }
//
//    }
//    func retrieveDatePortion(from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd" // Choose the desired date format
//
//        return dateFormatter.string(from: date)
//    }
//
//
//}

//struct AppointmentView: View {
//    var temp: String
//    var appointments: [Appointments]
//    var selectedDate: Date
//    @State private var searchText: String = ""
//    var filteredAppointments: [Appointments] {
//        if searchText.isEmpty {
//            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) }
//        } else {
//            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) && $0.patientName.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//
//    var body: some View {
//        VStack {
//            SearchBar(text: $searchText)
//
//            ForEach(filteredAppointments.indices, id: \.self) { index in
//                let appointment = filteredAppointments[index]
//                DisclosureGroup(
//                    content: {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("Patients for the Doctor")
//                                    .font(.subheadline)
//                                    .fontWeight(.bold)
//                                    .padding(.bottom, 5)
//
//                                Text(appointment.patientName)
//                                    .font(.custom("SF Pro Display", size: 16).weight(.semibold))
//                                    .tracking(0.16)
//                                    .lineSpacing(21.60)
//                                    .foregroundColor(.black)
//                            }
//                            .padding(.leading)
//
//                            Spacer()
//
//                            Image(systemName: "arrow.forward")
//                        }
//                        .frame(width: 218, height: 84)
//                        .background(.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .padding([.horizontal, .vertical], 5)
//                        .padding(.leading, 60)
//                    },
//                    label: {
//                        HStack {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .foregroundColor(Color("bg-color1"))
//                                    .frame(width: 86.78, height: 96)
//
//                                Text("\(temp)")
//                                    .font(.custom("SF Pro Display", size: 18).weight(.medium))
//                                    .foregroundColor(.white)
//                            }
//                            .frame(width: 86.78, height: 96)
//
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .foregroundColor(Color("bg-color1"))
//                                    .frame(width: 249.62, height: 96)
//
//                                VStack(alignment: .leading) {
//                                    Text("\(appointment.timeSlot!)")
//                                        .font(.custom("SF Pro Display", size: 16).weight(.semibold))
//                                        .foregroundColor(.white)
//                                        .padding(.bottom)
//
//                                    Text("Doctor Name: \(appointment.doctorName)")
//                                        .font(.custom("SF Pro Display", size: 14))
//                                        .foregroundColor(.white)
//                                }
//                                .offset(x: -30)
//                            }
//                            .frame(width: 249.62, height: 96)
//                        }
//                    }
//                )
//                .padding(.horizontal)
//            }
//        }
//        .onAppear {
//            print("appointments", appointments)
//        }
//    }
//
//    func retrieveDatePortion(from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd" // Choose the desired date format
//
//        return dateFormatter.string(from: date)
//    }
//}

//struct AppointmentAdminView: View {
//    var temp: String
//    var appointments: [Appointments]
//    var selectedDate: Date
//    @State private var searchText: String = ""
//    var filteredAppointments: [Appointments] {
//        if searchText.isEmpty {
//            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) }
//        } else {
//            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) && $0.patientName.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//
//    var body: some View {
//        VStack {
//            SearchBar(text: $searchText)
//
//            ForEach(filteredAppointments.indices, id: \.self) { index in
//                let appointment = filteredAppointments[index]
//                DisclosureGroup(
//                    content: {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                if index == 0 { // Only show the day box for the first appointment
//                                    Text("Patients for the Doctor")
//                                        .font(.subheadline)
//                                        .fontWeight(.bold)
//                                        .padding(.bottom, 5)
//
//                                    Text(appointment.patientName)
//                                        .font(.custom("SF Pro Display", size: 16).weight(.semibold))
//                                        .tracking(0.16)
//                                        .lineSpacing(21.60)
//                                        .foregroundColor(.black)
//                                } else {
//                                    Text(appointment.patientName)
//                                        .font(.custom("SF Pro Display", size: 16).weight(.semibold))
//                                        .tracking(0.16)
//                                        .lineSpacing(21.60)
//                                        .foregroundColor(.black)
//                                }
//                            }
//                            .padding(.leading)
//
//                            Spacer()
//
//                            Image(systemName: "arrow.forward")
//                        }
//                        .frame(width: 218, height: 84)
//                        .background(.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .padding([.horizontal, .vertical], 5)
//                        .padding(.leading, 60)
//                    },
//                    label: {
//                        HStack {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .foregroundColor(Color("bg-color1"))
//                                    .frame(width: 86.78, height: 96)
//
//                                Text("\(temp)")
//                                    .font(.custom("SF Pro Display", size: 18).weight(.medium))
//                                    .foregroundColor(.white)
//                            }
//                            .frame(width: 86.78, height: 96)
//
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .foregroundColor(Color("bg-color1"))
//                                    .frame(width: 249.62, height: 96)
//
//                                VStack(alignment: .leading) {
//                                    Text("\(appointment.timeSlot!)")
//                                        .font(.custom("SF Pro Display", size: 16).weight(.semibold))
//                                        .foregroundColor(.white)
//                                        .padding(.bottom)
//
//                                    Text("Doctor Name: \(appointment.doctorName)")
//                                        .font(.custom("SF Pro Display", size: 14))
//                                        .foregroundColor(.white)
//                                }
//                                .offset(x: -30)
//                            }
//                            .frame(width: 249.62, height: 96)
//                        }
//                    }
//                )
//                .padding(.horizontal)
//            }
//        }
//        .onAppear {
//            print("appointments", appointments)
//        }
//    }
//
//    func retrieveDatePortion(from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd" // Choose the desired date format
//
//        return dateFormatter.string(from: date)
//    }
//}

struct AppointmentAdminView: View {
    var temp: String
    var appointments: [Appointments]
    var selectedDate: Date
    @State private var searchText: String = ""
    var filteredAppointments: [Appointments] {
        if searchText.isEmpty {
            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) }
        } else {
            return appointments.filter { retrieveDatePortion(from: selectedDate) == retrieveDatePortion(from: $0.bookingDate) && $0.patientName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView{
            VStack {
                SearchBar(text: $searchText)
                
                ForEach(filteredAppointments.indices, id: \.self) { index in
                    let appointment = filteredAppointments[index]
                    DisclosureGroup(
                        content: {
                            HStack {
                                VStack(alignment: .leading) {
                                    if index == 0 { // Only show the day box for the first appointment
                                        
                                        Text(appointment.patientName)
                                            .font(.custom("SF Pro Display", size: 16).weight(.semibold))
                                            .tracking(0.16)
                                            .lineSpacing(21.60)
                                            .foregroundColor(.black)
                                    } else {
                                        // No day box for subsequent appointments
                                        Text(appointment.patientName)
                                            .font(.custom("SF Pro Display", size: 16).weight(.semibold))
                                            .tracking(0.16)
                                            .lineSpacing(21.60)
                                            .foregroundColor(.black)
                                            .padding(.leading, 60) // Adjust padding for alignment
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(width: 218, height: 84)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.horizontal, .vertical], 5)
                            .padding(.leading, index == 0 ? 60 : 0) // Adjust leading padding for the first appointment
                        },
                        label: {
                            HStack {
                                if(index == 0){
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(Color("bg-color1"))
                                            .frame(width: 86.78, height: 96)
                                        
                                        Text("\(temp)")
                                            .font(.custom("SF Pro Display", size: 18).weight(.medium))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 86.78, height: 96)
                                }
                                else{
                                    Spacer()
                                }
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("bg-color1"))
                                        .frame(width: 249.62, height: 96)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(appointment.timeSlot!)")
                                            .font(.custom("SF Pro Display", size: 16).weight(.semibold))
                                            .foregroundColor(.white)
                                            .padding(.bottom)
                                        
                                        Text("Doctor Name: \(appointment.doctorName)")
                                            .font(.custom("SF Pro Display", size: 14))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                }
                                .frame(width: 249.62, height: 96)
                            }
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .onAppear {
                print("appointments", appointments)
            }
        }
    }
    
    func retrieveDatePortion(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Choose the desired date format
        
        return dateFormatter.string(from: date)
    }
}




