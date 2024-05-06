//
//  MedicalTestDetailsView.swift
//  hms-structured
//
//  Created by Ishan on 06/05/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MedicalTestDetailsView: View {

    @State var testName: String
    @State var category: String
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @ObservedObject var indexDate = bookingCal
    @State private var showAlert = false

    var body: some View {

        VStack{

            HStack{
                Image(category)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))

                VStack{
                    Text(testName)
                        .font(.title)
                        .fontWeight(.bold)

                }
                .padding(.leading, 20)

                Spacer()
            }
            .padding(.horizontal)


            // Test booking
            VStack {

                HStack{

                    Text("Book your test")
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
                        TimeSlotView(time: "9:00 - 11:00", isSelected: selectedTime == "9:00 - 11:00") { time in
                            selectedTime = time
                        }
                        TimeSlotView(time: "11:00 - 12:00", isSelected: selectedTime == "11:00 - 12:00") { time in
                            selectedTime = time
                        }

                    }
                    .padding()
                    HStack(spacing: 20) {
                        // Time slots for morning set
                        TimeSlotView(time: "12:00 - 2:00", isSelected: selectedTime == "12:00 - 2:00") { time in
                            selectedTime = time
                        }
                        TimeSlotView(time: "2:00 - 4:00", isSelected: selectedTime == "2:00 - 4:00") { time in
                            selectedTime = time
                        }

                    }
                }
                .padding(.bottom, 20)



                Button(action: {
                    if let selectedTime = selectedTime {
                        medicalTestToFirestore(selectedDate: selectedDate, selectedTime: selectedTime, category: category, testName: testName , userName: userName, userUID: userUID)
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
                Alert(title: Text("Success"), message: Text("Medical Test booked successfully"), dismissButton: .default(Text("OK")))
            }
        }
    }

    func medicalTestToFirestore(selectedDate: Date, selectedTime: String, category: String, testName: String ,userName: String, userUID: String) {
        let medicalTestID = UUID().uuidString
        let medicalTest = [
            "bookingDate": selectedDate,
            "timeSlot": selectedTime,
            "category": category,
            "testName": testName,
            "patientName": userName,
            "patientID": userUID
        ] as [String : Any]

        let medicalTestsRef = Firestore.firestore().collection("medical-tests").document(userUID)

        medicalTestsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var medicalTestsMap = document.data() ?? [:]
                medicalTestsMap[medicalTestID] = medicalTest

                medicalTestsRef.setData(medicalTestsMap) { error in
                    if let error = error {
                        print("Error saving medical test: \(error)")
                    } else {
                        print("Medical test saved successfully")
                        showAlert = true
                    }
                }
            } else {
                let medicalTestsMap = [medicalTestID: medicalTest]

                medicalTestsRef.setData(medicalTestsMap) { error in
                    if let error = error {
                        print("Error saving medical test: \(error)")
                    } else {
                        print("Medical test saved successfully")
                        showAlert = true
                    }
                }
            }
        }
    }
}


#Preview {
    MedicalTestDetailsView(testName: "Ecg", category: "Cardiology")
}
