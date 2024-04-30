import Foundation
import FirebaseFirestoreSwift
struct Doctor: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var gender: String
    var dateOfBirth: Date
    var email: String
    var phone: String
    var emergencyContact: String
    var profileImageURL: String
    
    var employeeID: String
    var department: String
    var qualification: String
    var position: String
    var startDate: Date

    var licenseNumber: String
    var issuingOrganization: String
    var expiryDate: Date
    
    var description: String
    var yearsOfExperience: String

    enum CodingKeys: String, CodingKey {
        case id, fullName, gender, dateOfBirth, email, phone, emergencyContact, profileImageURL
        case employeeID, department, qualification, position, startDate
        case licenseNumber, issuingOrganization, expiryDate
        case description, yearsOfExperience
    }
}
