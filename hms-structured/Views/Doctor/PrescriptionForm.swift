import SwiftUI
import FirebaseFirestore

struct MedicineDetails {
    var dosage: Int = 1
    var selectedTimesOfDay: [String] = []
    var toBeTaken: String = "After Food"
}

struct Test: Identifiable {
    let id = UUID()
    let name: String
}

struct PrescriptionData {
    let patientID: String
    let patientName: String
    let doctorID: String
    let doctorName: String
    let symptoms: String
    let diagnosis: String
    let medicines: [[String: Any]]
    let tests: [[String: Any]]
    let suggestion: String
    let appointmentDate: Date // Add appointment date field
}

struct PrescriptionForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var symptoms = ""
    @State private var diagnosis = ""
    @State private var medicines: [Medicine] = []
    @State private var tests: [Test] = []
    @State private var selectedMedicine: Medicine? = nil
    @State private var selectedTest: Test? = nil
    @State private var dosage = 1
    @State private var selectedTimesOfDay: [String] = []
    @State private var toBeTaken = "After Food"
    @State private var suggestion = ""
    @State private var searchTextMedicine = ""
    @State private var searchTextTest = ""
    @State private var isEditingMedicine = false
    @State private var isEditingTest = false
    @State private var isEditingDetails = false
    @State private var selectedMedicineNames: Set<String> = []
    @State private var selectedTestNames: Set<String> = []
    var patientID = ""
    var patientName = ""
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var filteredMedicines: [Medicine] {
        if searchTextMedicine.isEmpty {
            return medicineList.filter { !selectedMedicineNames.contains($0.name) }
        } else {
            return medicineList.filter { $0.name.lowercased().contains(searchTextMedicine.lowercased()) && !selectedMedicineNames.contains($0.name) }
        }
    }

    var filteredTests: [Test] {
        if searchTextTest.isEmpty {
            return testList.filter { !selectedTestNames.contains($0.name) }
        } else {
            return testList.filter { $0.name.lowercased().contains(searchTextTest.lowercased()) && !selectedTestNames.contains($0.name) }
        }
    }
    
    var body: some View {
        
        NavigationStack{
            ScrollView{
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Patient : \(patientName)")
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Symptoms")
                    TextField("Enter symptoms", text: $symptoms).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Diagnosis")
                    TextField("Enter diagnosis", text: $diagnosis)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Medication")
                        .font(.headline)
                    VStack() {
                        VStack() {
                            HStack {
                                TextField("Search for medicine", text: $searchTextMedicine, onEditingChanged: { editing in
                                    self.isEditingMedicine = editing
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                Spacer()
                                Spacer()
                                if isEditingMedicine {
                                    Button(action: {
                                        self.searchTextMedicine = ""
                                        self.isEditingMedicine = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                        
                                    }
                                }
                            }
                            
                            .background(Color.white)
                            .cornerRadius(8)
                            
                            if !medicines.isEmpty {
                                ForEach(medicines) { medicine in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            
                                            Button(action: {
                                                self.selectedMedicine = medicine
                                                self.isEditingDetails.toggle()
                                            }) {
                                                Text("\(medicine.name)").bold()
                                                    .foregroundStyle(Color.black)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.blue)
                                            }
                                            Button(action: {
                                                self.medicines.removeAll { $0.id == medicine.id }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        if isEditingDetails && selectedMedicine?.id == medicine.id {
                                            Text("Dosage")
                                            HStack {
                                                Button(action: {
                                                    // Functionality to increase dosage
                                                    self.medicines[self.medicines.firstIndex(where: { $0.id == medicine.id })!].medicineDetails.dosage += 1
                                                }) {
                                                    Text("+")
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                                                }
                                                
                                                Text("\(medicine.medicineDetails.dosage) tablet") .foregroundColor(.blue)
                                                    .padding()
                                                
                                                
                                                Button(action: {
                                                    // Functionality to decrease dosage
                                                    if medicine.medicineDetails.dosage > 1 {
                                                        self.medicines[self.medicines.firstIndex(where: { $0.id == medicine.id })!].medicineDetails.dosage -= 1
                                                    }
                                                }) {
                                                    Text("-")
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                                                }
                                            }
                                            Divider()
                                            Text("Time of the Day")
                                            HStack {
                                                ForEach(["Morning", "Noon", "Night"], id: \.self) { time in
                                                    Button(action:{
                                                        if medicine.medicineDetails.selectedTimesOfDay.contains(time){
                                                            self.medicines[self.medicines.firstIndex(where: { $0.id == medicine.id })!].medicineDetails.selectedTimesOfDay.removeAll(where: {$0 == time})
                                                        }
                                                        else{
                                                            self.medicines[self.medicines.firstIndex(where: { $0.id == medicine.id })!].medicineDetails.selectedTimesOfDay.append(time)
                                                        }
                                                    }){
                                                        Text(time)
                                                            .padding(8)
                                                            .foregroundStyle(medicine.medicineDetails.selectedTimesOfDay.contains(time) ? Color.white : Color.black)
                                                            .background(medicine.medicineDetails.selectedTimesOfDay.contains(time) ? Color("bg-color1") : Color.white)
                                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    }
                                                }
                                            }
                                            Divider()
                                            Text("To be Taken")
                                            Picker("To be Taken", selection: $toBeTaken) {
                                                Text("After Food").tag("After Food").foregroundColor(.blue)
                                                Text("Before Food").tag("Before Food").foregroundColor(.blue)
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                            .background(Color.white)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            if isEditingMedicine {
                                List(filteredMedicines) { medicine in
                                    Button(action: {
                                        self.medicines.append(medicine)
                                        self.selectedMedicineNames.insert(medicine.name) // Add selected medicine name to set
                                        self.isEditingMedicine = false
                                        self.searchTextMedicine = ""
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }) {
                                        Text(medicine.name)
                                    }
                                }
                                .listStyle(PlainListStyle())
                                .frame(width: 320,height: 250)
                            }
                        }
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tests")
                    VStack() {
                        VStack() {
                            TextField("Search for test", text: $searchTextTest, onEditingChanged: { editing in
                                self.isEditingTest = editing
                            }).textFieldStyle(RoundedBorderTextFieldStyle())
                            
                                .overlay(
                                    HStack {
                                        Spacer()
                                        if isEditingTest {
                                            Button(action: {
                                                self.searchTextTest = ""
                                                self.isEditingTest = false
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .background(Color.white)
                                                    .cornerRadius(20)
                                                    .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                )
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            if !tests.isEmpty {
                                ForEach(tests) { test in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text("\(test.name)").bold()
                                            Spacer()
                                            Button(action: {
                                                self.tests.removeAll { $0.id == test.id }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 5)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            if isEditingTest {
                                List(filteredTests) { test in
                                    Button(action: {
                                        self.tests.append(test)
                                        self.isEditingTest = false
                                        self.searchTextTest = ""
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }) {
                                        Text(test.name)
                                    }
                                }
                                .listStyle(PlainListStyle())
                                .frame(width: 320,height: 250)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Suggetion")
                    TextField("Enter suggestions",text: $suggestion).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    // Submit to Firebase
                    let prescriptionData = PrescriptionData(
                        patientID: patientID,
                        patientName: patientName,
                        doctorID: userUID,
                        doctorName: userName,
                        symptoms: symptoms,
                        diagnosis: diagnosis,
                        medicines: medicines.map { medicine in
                            return [
                                "name": medicine.name,
                                "details": medicine.details,
                                "dosage": medicine.medicineDetails.dosage,
                                "selectedTimesOfDay": medicine.medicineDetails.selectedTimesOfDay,
                                "toBeTaken": medicine.medicineDetails.toBeTaken
                            ]
                        },
                        tests: tests.map { test in
                            return [
                                "name": test.name
                            ]
                        },
                        suggestion: suggestion,
                        appointmentDate: Date() // Current date as appointment date
                    )
                    
                    let prescriptionDictionary: [String: Any] = [
                        "patientID": prescriptionData.patientID,
                        "patientName": prescriptionData.patientName,
                        "doctorID": prescriptionData.doctorID,
                        "doctorName": prescriptionData.doctorName,
                        "symptoms": prescriptionData.symptoms,
                        "diagnosis": prescriptionData.diagnosis,
                        "medicines": prescriptionData.medicines,
                        "tests": prescriptionData.tests,
                        "suggestion": prescriptionData.suggestion,
                        "appointmentDate": prescriptionData.appointmentDate // Include appointment date
                    ]
                    
                    // Add prescriptionData to Firebase
                    let db = Firestore.firestore()
                    db.collection("prescriptions").addDocument(data: prescriptionDictionary) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully")
                            // Clear form fields
                            symptoms = ""
                            diagnosis = ""
                            medicines = []
                            tests = []
                            suggestion = ""
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(red: 239/255, green: 239/255, blue: 239/255))
            .cornerRadius(10)
            .padding()
            .onAppear(){
                print(userName)
                print(userUID)
            }
            .navigationTitle("Prescription")
        }
    }
    }
}

struct PrescriptionForm_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionForm()
    }
}
