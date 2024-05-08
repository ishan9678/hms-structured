import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct MedicalTest: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let bookingDate: Date
    let category: String
    let patientID: String
    let patientName: String
    let testName: String
    let timeSlot: String
}

struct ReportsView: View {
    @State var fetchedMedicalTests: [MedicalTest] = []
    @Binding var searchText: String 
    var filiteredMedicalTests:[MedicalTest]{
        if searchText.isEmpty{
            return fetchedMedicalTests
        }else{
            return fetchedMedicalTests.filter{$0.testName.localizedCaseInsensitiveContains(searchText)}
        }
    }
    var body: some View {
        VStack {
//            Text("Reports").font(.title)
            List(filiteredMedicalTests) { test in
                HStack{
                    if test.category == "Blood Test" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "X-Ray" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "Biopsy" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "CT-Scan" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "Endoscopic Procedures" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "Neurological" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "Cardiac-Tests" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else if test.category == "Cancer Test" {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(test.category)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    }
                    VStack(alignment: .leading) {
                        Text("\(test.testName)")
                            .fontWeight(.bold)
                            .font(.system(size: 25))
                        
                        Text("\(test.category)")
                            .foregroundColor(.black.opacity(0.6))
                        
                        
                        Text("Booking Date: \(formattedDate(test.bookingDate))")
                        
                        Text("Time Slot: \(test.timeSlot)")
                        
                    }
                    .padding()
                   
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 25))
                }.frame(width:360,height: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal,20)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchMedicalTest()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter.string(from: date)
        
    }
    
    private func fetchMedicalTest() {
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }

        db.collection("medical-tests").document(userId).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("Document does not exist")
                return
            }
            
            guard let data = document.data() else {
                print("Document data is empty")
                return
            }
            
            var medicalTests: [MedicalTest] = []
            
            for (documentID, map) in data {
                if let mapData = map as? [String: Any],
                   let bookingDateTimestamp = mapData["bookingDate"] as? Timestamp {
                    let bookingDate = bookingDateTimestamp.dateValue()
                    let medicalTest = MedicalTest(
                        id: documentID,
                        bookingDate: bookingDate,
                        category: mapData["category"] as? String ?? "",
                        patientID: mapData["patientID"] as? String ?? "",
                        patientName: mapData["patientName"] as? String ?? "",
                        testName: mapData["testName"] as? String ?? "",
                        timeSlot: mapData["timeSlot"] as? String ?? ""
                    )
                    medicalTests.append(medicalTest)
                }
            }
            
            fetchedMedicalTests = medicalTests
        }
    }
}


//#Preview {
//
//    ReportsView(, searchText: searcht)
//
//}
