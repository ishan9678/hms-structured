//
//  MedicalTestCardView.swift
//  hms-structured
//
//  Created by Ishan on 09/05/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MedicalTestCard: View {
    let medicalTest: MedicalTest
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text(getDate(date: medicalTest.bookingDate))
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 50, height: 50)
                        .background(Color("bg-color1"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                    Text(medicalTest.timeSlot ?? " ")
                        .font(.system(size: 15))
                }

                VStack{
                    Text(medicalTest.testName)
                }

            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .contextMenu {
            Button {
                onDelete()
            } label: {
                Label("Cancel Medical Test", systemImage: "trash")
            }
        }
    }

    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }

}

struct PatientMedicalTestsView: View {
    @State private var fetchedMedicalTests: [MedicalTest] = []
    @State private var isLoading = false

    var body: some View {
        VStack {
            HStack {
                Text("Upcoming Medical Tests")
                    .padding(.leading, 25)
                    .font(.headline)
                Spacer()
                Button("May 2024") {}
                    .padding(.trailing, 25)
                    .font(.headline)
            }
            .background(Color.white)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 50)
            } else if fetchedMedicalTests.isEmpty {
                Text("No upcoming medical tests")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(fetchedMedicalTests.enumerated()), id: \.element) { index, medicalTest in
                            VStack {
                                MedicalTestCard(medicalTest: medicalTest){
                                    deleteMedicalTest(medicalTest: medicalTest)
                                }
                                .frame(width: 230)
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                    .padding([.horizontal,.bottom])
                    .padding(.top,0.5)
                }
            }
        }
        .onAppear {
            Task {
                isLoading = true
                do {
                    try await fetchMedicalTests()
                    isLoading = false
                } catch {
                    print(error)
                }
            }
        }
    }

    func fetchMedicalTests() async {
        do {
            fetchedMedicalTests = []
            let db = Firestore.firestore()

            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not logged in")
                return
            }

            let document = try await db.collection("medical-tests").document(userId).getDocument()
            guard let data = document.data() else {
                print("Document does not exist or data is nil")
                return
            }

            for (key , medicalTestData) in data {
                if let medicalTestData = medicalTestData as? [String: Any] {
                    if let bookingDateTimestamp = medicalTestData["bookingDate"] as? Timestamp {
                        let bookingDate = Date(timeIntervalSince1970: TimeInterval(bookingDateTimestamp.seconds))
                        let medicalTest = MedicalTest(id: key , bookingDate: bookingDate, category: medicalTestData["category"] as? String ?? "", patientID: medicalTestData["patientID"] as? String ?? "", patientName: medicalTestData["patientName"] as? String ?? "", testName: medicalTestData["testName"] as? String ?? "", timeSlot: medicalTestData["timeSlot"] as? String ?? "", pdfURL: medicalTestData["pdfURL"] as? String ?? "")
                        fetchedMedicalTests.append(medicalTest)
                    }
                }
            }
            fetchedMedicalTests.sort { $0.bookingDate < $1.bookingDate }

        } catch {
            print("Error fetching document: \(error)")
        }
    }

    func deleteMedicalTest(medicalTest: MedicalTest) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid

        let documentRef = db.collection("medical-tests").document(userId!)

        documentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                print("Document does not exist")
                return
            }

            guard var medicalTestsMap = snapshot.data() as? [String: Any] else {
                print("Document data is empty")
                return
            }

            medicalTestsMap.removeValue(forKey: medicalTest.id ?? "")

            documentRef.setData(medicalTestsMap) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Medical Test successfully deleted")
                    Task{
                        await fetchMedicalTests()
                    }
                }
            }
        }
    }
}


