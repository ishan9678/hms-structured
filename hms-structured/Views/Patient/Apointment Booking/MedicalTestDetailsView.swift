//
//  MedicalTestDetailsView.swift
//  hms-structured
//
//  Created by Ishan on 06/05/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct MedicalTestDetailsView: View {
    
    @State var testName: String
    @State var category: String
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @ObservedObject var indexDate = bookingCal
    @State private var showAlert = false
    @State private var availabilityCounts: [String: Int] = [
        "9:00 - 11:00": 0,
        "11:00 - 12:00": 0,
        "12:00 - 2:00": 0,
        "2:00 - 4:00": 0
    ]
    
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
        .onAppear {
            checkTestSlotAvailability(selectedDate: selectedDate, testName: testName) { TestTimeSlotAvailability in
                availabilityCounts["9:00 - 11:00"] = TestTimeSlotAvailability.slotCounts["9:00 - 11:00"]
                availabilityCounts["11:00 - 12:00"] = TestTimeSlotAvailability.slotCounts["11:00 - 12:00"]
                availabilityCounts["12:00 - 2:00"] = TestTimeSlotAvailability.slotCounts["12:00 - 2:00"]
                availabilityCounts["2:00 - 4:00"] = TestTimeSlotAvailability.slotCounts["2:00 - 4:00"]
                print("avai", TestTimeSlotAvailability.slotCounts["9:00 - 11:00"])
            }
        }
        .onReceive(Just(selectedDate)) { _ in
                checkTestSlotAvailability(selectedDate: selectedDate, testName: testName) {
                    TestSlotAvailability in
                    print(TestSlotAvailability.slotCounts)
                    print("Selected date change", selectedDate)
                    availabilityCounts["9:00 - 11:00"] = TestSlotAvailability.slotCounts["9:00 - 11:00"]
                    availabilityCounts["11:00 - 12:00"] = TestSlotAvailability.slotCounts["11:00 - 12:00"]
                    availabilityCounts["12:00 - 2:00"] = TestSlotAvailability.slotCounts["12:00 - 2:00"]
                    availabilityCounts["2:00 - 4:00"] = TestSlotAvailability.slotCounts["2:00 - 4:00"]
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
    
    func checkTestSlotAvailability(selectedDate: Date, testName: String, completion: @escaping (TestTimeSlotAvailability) -> Void){
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        print("selected date", selectedDate)
        
        var testTimeSlotAvailability = TestTimeSlotAvailability()
        
        db.collection("medical-tests").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting medical tests: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No medical tests found")
                return
            }
            
            print("fn called")
            
            for document in documents {
                let data = document.data()
                
                for (_, testSlotData) in data {
                    if let testSlotData = testSlotData as? [String: Any] {
                        if let testNameInData = testSlotData["testName"] as? String, testNameInData == testName {
                            if let bookingDateTimestamp = testSlotData["bookingDate"] as? Timestamp {
                                let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                                
                                // Compare the bookingDate with the selectedDate
                                if Calendar.current.isDate(bookingDate, inSameDayAs: selectedDate) {
                                    if let timeSlot = testSlotData["timeSlot"] as? String {
                                        if var count = testTimeSlotAvailability.slotCounts[timeSlot] {
                                            count += 1
                                            testTimeSlotAvailability.slotCounts[timeSlot] = count
                                            print("count", count)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            print("slotCounts", testTimeSlotAvailability.slotCounts)
            completion(testTimeSlotAvailability)
        }
    }
    
    
    struct TestTimeSlotAvailability {
        var slotCounts: [String: Int] = [
            "9:00 - 11:00": 0,
            "11:00 - 12:00": 0,
            "12:00 - 2:00": 0,
            "2:00 - 4:00": 0
        ]
    }
    
}

#Preview {
    MedicalTestDetailsView(testName: "Ecg", category: "Cardiology")
}
