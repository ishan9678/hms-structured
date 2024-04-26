import SwiftUI

struct DoctorDetailsView: View {
    var doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image("doctor_placeholder") // Use an image for the doctor's photo
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(doctor.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(doctor.department)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
//                        Text(String(format: "%.1f", doctor.rating))
//                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                    
                    Text("Years of Exp: \(doctor.yearsOfExperience)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Description:")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(doctor.description)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
    }
}

// Preview
struct DoctorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let doctor = Doctor(id: "1", fullName: "Dr. John Doe", gender: "Male", dateOfBirth: Date(), email: "john.doe@example.com", phone: "1234567890", emergencyContact: "9876543210", employeeID: "EMP001", department: "Cardiology", qualification: "MBBS", position: "Cardiologist", startDate: Date(), licenseNumber: "LIC001", issuingOrganization: "Medical Board", expiryDate: Date(), description: "Lorem ipsum dolor sit amet", yearsOfExperience: "5")
        return DoctorDetailsView(doctor: doctor)
            .previewLayout(.sizeThatFits)
    }
}

