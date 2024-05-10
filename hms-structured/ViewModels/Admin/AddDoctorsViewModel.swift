//
//  DoctorsViewModel.swift
//  HMS-Team 5
//
//  Created by Ishan on 22/04/24.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class AddDoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []

    private var db = Firestore.firestore()

    func fetchDoctors() {
        db.collection("doctors").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let querySnapshot = querySnapshot {
                // Initialize an empty array to store fetched doctors
                var fetchedDoctors: [Doctor] = []

                // Iterate over each document returned from the Firestore collection
                for document in querySnapshot.documents {
                    do {
                        // Attempt to decode the document into a Doctor object
                        // Note: Make sure the Doctor model conforms to Decodable or is compatible with Firestore's data model
                        var doctor = try document.data(as: Doctor.self)
                        print(doctor.id)
                        fetchedDoctors.append(doctor)
                    } catch let decodeError {
                        print("Error decoding doctor: \(decodeError)")
                        
                    }
                }

                // Update the UI on the main thread since Firestore completion handler is executed on a background thread
                DispatchQueue.main.async {
                    self.doctors = fetchedDoctors
                }
            }
        }
    }


    func addDoctor(doctor: Doctor, image: UIImage?) {
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = Storage.storage().reference().child("doctorProfileImages/\(UUID().uuidString).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("Error uploading image: \(String(describing: error))")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting URL: \(String(describing: error))")
                    return
                }

                
                
                // Proceed to save the Doctor object in Firestore
                Task{
                    var doctor1 = doctor
                    doctor1.profileImageURL = downloadURL.absoluteString
                    do {await self.saveDoctorToFirestore(doctor: doctor1)
                }
                    catch {
                        print(error)
                    }
                }
            }
        }
    }

    private func saveDoctorToFirestore(doctor: Doctor) async {
        do {
            // Create a new user with email and password
            let result = try await Auth.auth().createUser(withEmail: doctor.email, password: "Gmail@123")
            
            // result.user.uid gives us the newly created user ID
            let userId = result.user.uid
            print(userId)
            
            // Use the user ID as the document ID in the Firestore doctors collection
            try await db.collection("doctors").document(userId).setData(from: doctor)
            
            print("Doctor added successfully with user ID: \(userId)")
            self.fetchDoctors() // Optionally refresh the doctors list
        } catch let error {
            print("Error in saving doctor: \(error)")
        }
    }

    
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user:", error.localizedDescription)
                return
            }
            
            // User created
            if let user = authResult?.user {
                print("User created successfully:", user.uid)
                 
            }
        }
    }
    
    func deleteDoctor(doctorId: String) {
        db.collection("doctors").document(doctorId).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                DispatchQueue.main.async {
                    self.doctors.removeAll { $0.id == doctorId } // Remove doctor from the local list
                    print("Doctor with ID \(doctorId) has been successfully deleted from Firestore.")
                }
            }
        }
    }


}
