//
//  AddNursesViewModel.swift
//  hms
//
//  Created by Divyanshu Pabia on 30/04/24.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class AddNursesViewModel: ObservableObject {
    @Published var nurses: [Nurse] = []

    private var db = Firestore.firestore()

    func fetchNurse() {
        db.collection("nurses").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let querySnapshot = querySnapshot {
                var fetchedNurses: [Nurse] = []
                
                for document in querySnapshot.documents {
                    do {
                        let nurse = try document.data(as: Nurse.self)
                        fetchedNurses.append(nurse)
                    } catch let decodeError {
                        print("Error decoding nurse: \(decodeError)")
                    }
                }

                DispatchQueue.main.async {
                    self.nurses = fetchedNurses
                }
            }
        }
    }


    func addNurse(nurse: Nurse, image: UIImage?) {
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = Storage.storage().reference().child("nurseProfileImages/\(UUID().uuidString).jpg")

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
                nurse.profileImageURL = downloadURL.absoluteString

                Task{
                    do {await self.saveNurseToFirestore(nurse: nurse)
                }
                    catch {
                        print(error)
                    }
                }
            }
        }
    }

    private func saveNurseToFirestore(nurse: Nurse) async {
        do {
            // Create a new user with email and password
            let result = try await Auth.auth().createUser(withEmail: nurse.email, password: "Gmail@123")

            let userId = result.user.uid
            print(userId)

            try await db.collection("nurses").document(userId).setData(from: nurse)
            
            print("Nurse added successfully with user ID: \(userId)")
            self.fetchNurse()
        } catch let error {
            print("Error in saving nurse: \(error)")
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

}

