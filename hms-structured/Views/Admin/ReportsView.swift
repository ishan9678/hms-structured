import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct MedicalTest: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let bookingDate: Date
    let category: String
    let patientID: String
    let patientName: String
    let testName: String
    let timeSlot: String
    let pdfURL: String? // URL to the PDF file in Firebase Storage
}

struct AdminReportsView: View {
    @State private var fetchedMedicalTests = [MedicalTest]()
    @State private var pdfData: Data?
    @State private var showFilePicker: Bool = false

    var body: some View {
        VStack {
            Text("Medical Tests").font(.title)
            List(fetchedMedicalTests) { test in
                VStack(alignment: .leading) {
                    Text("Test Name: \(test.testName)")
                    Text("Category: \(test.category)")
                    Text("Patient Name: \(test.patientName)")
                    Text("Booking Date: \(formattedDate(test.bookingDate))")
                    Text("Time Slot: \(test.timeSlot)")
                    if let pdfURL = test.pdfURL {
                        Link("View PDF", destination: URL(string: pdfURL)!)
                    } else {
                        Text("PDF not available")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .listStyle(PlainListStyle())
            Button(action: {
                            showFilePicker.toggle()
                        }) {
                            Text("Upload PDF")
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
        .onAppear {
            fetchMedicalTest()
        }
    }

    
    private func uploadPDF(fileURL: URL) {
            guard let data = try? Data(contentsOf: fileURL) else { return }
            
            // Set PDF data
            pdfData = data
            
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
            // Assuming you have a collection named "pdfs" in Firestore to store PDF download URLs
            db.collection("pdfs").addDocument(data: ["url": url]) { error in
                if let error = error {
                    print("Error saving PDF download URL: \(error.localizedDescription)")
                } else {
                    print("PDF download URL saved successfully")
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
            do {
                if let data = document.data() {
                    var medicalTests = [MedicalTest]()
                    for (_, medicalTestData) in data {
                        if let medicalTestData = medicalTestData as? [String: Any], let bookingDateTimestamp = medicalTestData["bookingDate"] as? Timestamp {
                            let bookingDate = bookingDateTimestamp.dateValue()
                            let medicalTest = MedicalTest(
                                bookingDate: bookingDate,
                                category: medicalTestData["category"] as? String ?? "",
                                patientID: medicalTestData["patientID"] as? String ?? "",
                                patientName: medicalTestData["patientName"] as? String ?? "",
                                testName: medicalTestData["testName"] as? String ?? "",
                                timeSlot: medicalTestData["timeSlot"] as? String ?? "",
                                pdfURL: medicalTestData["pdfURL"] as? String // Assuming you store PDF URL in Firestore
                            )
                            medicalTests.append(medicalTest)
                        }
                    }
                    medicalTests.sort { $0.bookingDate < $1.bookingDate }
                    fetchedMedicalTests = medicalTests
                }
            } catch {
                print("Error decoding document: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {

    AdminReportsView()

}

