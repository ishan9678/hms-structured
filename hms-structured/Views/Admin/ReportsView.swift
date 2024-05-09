
import SwiftUI
import FirebaseFirestore
import FirebaseStorage



struct AdminReportsView: View {
    @State private var fetchedMedicalTests = [MedicalTest]()
    @State private var pdfData: Data?
    @State private var showFilePicker: Bool = false
    @State private var selectedTestID: String = ""
    @State private var searchText: String = ""

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
                        print(selectedTestID)
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
                            self.uploadPDF(fileURL: selectedFile)
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
            fetchMedicalTest()
        }
    }

    private func uploadPDF(fileURL: URL) {
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
            savePDFDownloadURL(url: metadata.path ?? "")
        }
    }

    private func savePDFDownloadURL(url: String) {
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
            db.collection("medical-tests").document("P71IKQYzK4QsPyDnPCWrQsa5ac72")
                .updateData([
                    "\(selectedTestID).pdfURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Error updating PDF URL: \(error.localizedDescription)")
                    } else {
                        print("PDF URL updated successfully")
                    }
                }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return dateFormatter.string(from: date)
    }

    private func fetchMedicalTest() {

        let db = Firestore.firestore()

        db.collection("medical-tests").document("P71IKQYzK4QsPyDnPCWrQsa5ac72").getDocument { documentSnapshot, error in

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

                        pdfURL: " "
                    )

                    medicalTests.append(medicalTest)

                }

            }

            fetchedMedicalTests = medicalTests

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



