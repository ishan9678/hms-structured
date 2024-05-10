import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct AdminReportsView: View {
    // State variables
    @State private var fetchedMedicalTests = [MedicalTest]()
    @State private var pdfData: Data?
    @State private var showFilePicker: Bool = false
    @State private var selectedTestID: String = ""
    @State private var searchText: String = ""
    @State private var patientID: String = ""
    @State private var showAlert = false // State variable for showing alert

    var filteredTests: [MedicalTest] {
        if searchText.isEmpty {
            return fetchedMedicalTests
        } else {
            return fetchedMedicalTests.filter { $0.patientName.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(alignment: .leading){
            Text("Medical Tests").font(.title).padding()
            SearchBar(text: $searchText)
            List(filteredTests) { test in
                VStack(alignment: .leading) {
                    Text("\(test.patientName)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                    Text("\(test.testName)") .font(.system(size: 18))
                    Text("\(test.category)") .foregroundColor(.black.opacity(0.6))
                    Text("Booking Date: \(formattedDate(test.bookingDate))")
                    Text("Time Slot: \(test.timeSlot)")
                    Button(action: {
                        selectedTestID = test.id ?? ""
                        patientID = test.patientID
                        showFilePicker.toggle()
                    }) {
                        HStack{
                            Text("Upload PDF").bold()
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                        }.foregroundColor(.blue).padding(2)
                    }
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
                        do {
                            let selectedFile = try result.get()
                            self.uploadPDF(fileURL: selectedFile, patientID: patientID, selectedTestID: selectedTestID)
                        } catch {
                            print("File selection error: \(error.localizedDescription)")
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchMedicalTests()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text("PDF uploaded successfully"), dismissButton: .default(Text("OK")))
        }
    }

    private func uploadPDF(fileURL: URL, patientID: String, selectedTestID: String) {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        
        // Upload PDF to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let pdfRef = storageRef.child("pdfs/\(UUID().uuidString).pdf")
        
        pdfRef.putData(data, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("Error uploading PDF: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("PDF uploaded. Download URL: \(metadata.path ?? "Unknown")")
            
            // Add the PDF download URL to Firestore
            savePDFDownloadURL(url: metadata.path ?? "", patientID: patientID, selectedTestID: selectedTestID)
        }
    }

    private func savePDFDownloadURL(url: String, patientID: String, selectedTestID: String  ) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
    
        // Get the reference to the uploaded PDF file
        let pdfRef = storage.reference().child(url)
        
        // Get the download URL for the uploaded PDF file
        pdfRef.downloadURL { downloadURL, error in
            guard let downloadURL = downloadURL, error == nil else {
                print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Update the medical test entry in Firestore with the download URL
            db.collection("medical-tests").document(patientID)
                .updateData([
                    "\(selectedTestID).pdfURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Error updating PDF URL: \(error.localizedDescription)")
                    } else {
                        print("PDF URL updated successfully")
                        showAlert = true // Set showAlert to true to display the alert
                    }
                }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return dateFormatter.string(from: date)
    }

    func fetchMedicalTests() {
        let db = Firestore.firestore()
        
        db.collection("medical-tests").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting appointments: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No appointments found")
                return
            }
        
            fetchedMedicalTests = []
            for document in documents {
                let data = document.data()
                
                for (documentID, medicalTestData) in data {
                    print("doc id", documentID)
    
                    if let medicalTestData = medicalTestData as? [String: Any] {
                        if let bookingDateTimestamp = medicalTestData["bookingDate"] as? Timestamp {
                            let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                            let medicalTest = MedicalTest(id: documentID, bookingDate: bookingDate, category: medicalTestData["category"] as? String ?? "", patientID: medicalTestData["patientID"] as? String ?? "", patientName: medicalTestData["patientName"] as? String ?? "", testName: medicalTestData["testName"] as? String ?? "", timeSlot: medicalTestData["timeSlot"] as? String ?? "", pdfURL: medicalTestData["pdfURL"] as? String ?? "")
                            print("pdf exits or not",medicalTestData["pdfURL"])
                            if(medicalTestData["pdfURL"] == nil){
                                fetchedMedicalTests.append(medicalTest)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(4)
                }
            }
        }
    }
}

#Preview {

    AdminReportsView()

}

