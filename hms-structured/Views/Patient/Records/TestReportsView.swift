import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import ShareSheetView


struct MedicalTest: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let bookingDate: Date
    let category: String
    let patientID: String
    let patientName: String
    let testName: String
    let timeSlot: String
    let pdfURL: String
}

struct ReportsView: View {
    let patientID: String
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
                            .font(.system(size: 16))
                        
                        Text("\(test.category)")
                            .foregroundColor(.black.opacity(0.6))
                        
                        
                        Text("Booking Date: \(formattedDate(test.bookingDate))")
                        
                        Text("Time Slot: \(test.timeSlot)")
                        HStack(spacing:30){
                            RoundedRectangle(cornerRadius: 30)
                                .fill(test.pdfURL.isEmpty ? Color.blue : Color.green)
                                .frame(width: 150,height: 30)
                                .overlay(Text(test.pdfURL.isEmpty ? "In-progress":"Completed")
                                    .foregroundColor(.white))
                            if test.pdfURL.isEmpty{
                                
                            }else{
                                Button(action: {
                                    downloadPDF(url: test.pdfURL)
                                }) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 25))
                                }
                            }
                        }
                    }
                    .padding()
                   
                  
                    
                }.frame(width:360,height: 170)
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
        


        db.collection("medical-tests").document(patientID).getDocument { documentSnapshot, error in
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
                        timeSlot: mapData["timeSlot"] as? String ?? "",
                        pdfURL: mapData["pdfURL"] as? String ?? ""
                    )
                    medicalTests.append(medicalTest)
                }
            }
            
            fetchedMedicalTests = medicalTests
        }
    }
    func downloadPDF(url : String){
        if let URl = URL(string: url){
            let storageRef = Storage.storage().reference(forURL: url)
            let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(URl.lastPathComponent).appendingPathExtension("pdf")
            let dowloadTask = storageRef.write(toFile: destination){
                url, error in
                if let error = error{
                    print("Failed to Download")
                }
                else{
                    print("Downloaded")
                    let activityViewController = UIActivityViewController(activityItems: [destination], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
        
    }
}


//#Preview {
//
//    ReportsView(searchText:.constant(""))
//
//}
