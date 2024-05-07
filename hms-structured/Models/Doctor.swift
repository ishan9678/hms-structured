//
//  Doctors.swift
//  HMS-Team 5
//
//  Created by Ishan on 22/04/24.
//

import Foundation
import SwiftUI

class Doctors: ObservableObject, Identifiable, Codable {
    @Published var id: String?
    @Published var profileImageURL: String?
    
    @Published var fullName: String
    @Published var gender: String
    @Published var dateOfBirth: Date
    @Published var email: String
    @Published var phone: String
    @Published var emergencyContact: String
    
    @Published var employeeID: String
    @Published var department: String
    @Published var qualification: String
    @Published var position: String
    @Published var startDate: Date


    @Published var licenseNumber: String
    @Published var issuingOrganization: String
    @Published var expiryDate: Date
    
    @Published var description: String
    @Published var yearsOfExperience: String

    enum CodingKeys: String, CodingKey {
        case profileImageURL
        case fullName, gender, dateOfBirth, email, phone, emergencyContact
        case employeeID, department, qualification, position, startDate
        case licenseNumber, issuingOrganization, expiryDate
        case description, yearsOfExperience
    }
    
    init(profileImageURL: String? = nil, fullName: String, gender: String, dateOfBirth: Date, email: String, phone: String,
             emergencyContact: String, employeeID: String, department: String, qualification: String,
             position: String, startDate: Date, licenseNumber: String, issuingOrganization: String,
             expiryDate: Date, description: String, yearsOfExperience: String) {
            self.profileImageURL = profileImageURL
            self.fullName = fullName
            self.gender = gender
            self.dateOfBirth = dateOfBirth
            self.email = email
            self.phone = phone
            self.emergencyContact = emergencyContact
            self.employeeID = employeeID
            self.department = department
            self.qualification = qualification
            self.position = position
            self.startDate = startDate
            self.licenseNumber = licenseNumber
            self.issuingOrganization = issuingOrganization
            self.expiryDate = expiryDate
            self.description = description
            self.yearsOfExperience = yearsOfExperience
        }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.dateOfBirth = try container.decode(Date.self, forKey: .dateOfBirth)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.emergencyContact = try container.decode(String.self, forKey: .emergencyContact)
        
        self.employeeID = try container.decode(String.self, forKey: .employeeID)
        self.department = try container.decode(String.self, forKey: .department)
        self.qualification = try container.decode(String.self, forKey: .qualification)
        self.position = try container.decode(String.self, forKey: .position)
        self.startDate = try container.decode(Date.self, forKey: .startDate)


        self.licenseNumber = try container.decode(String.self, forKey: .licenseNumber)
        self.issuingOrganization = try container.decode(String.self, forKey: .issuingOrganization)
        self.expiryDate = try container.decode(Date.self, forKey: .expiryDate)
        
        self.description = try container.decode(String.self, forKey: .description)
        self.yearsOfExperience = try container.decode(String.self, forKey: .yearsOfExperience)

    }
    
    func toDictionary() -> [String: Any] {
           return [
               "id": id ?? "",
               "profileImageURL": profileImageURL ?? "",
               "fullName": fullName,
               "gender": gender,
               "dateOfBirth": dateOfBirth,
               "email": email,
               "phone": phone,
               "emergencyContact": emergencyContact,
               "employeeID": employeeID,
               "department": department,
               "qualification": qualification,
               "position": position,
               "startDate": startDate,
               "licenseNumber": licenseNumber,
               "issuingOrganization": issuingOrganization,
               "expiryDate": expiryDate,
               "description": description,
               "yearsOfExperience": yearsOfExperience
           ]
       }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        
        try container.encode(fullName, forKey: .fullName)
        try container.encode(gender, forKey: .gender)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(emergencyContact, forKey: .emergencyContact)
        
        try container.encode(employeeID, forKey: .employeeID)
        try container.encode(department, forKey: .department)
        try container.encode(qualification, forKey: .qualification)
        try container.encode(position, forKey: .position)
        try container.encode(startDate, forKey: .startDate)


        try container.encode(licenseNumber, forKey: .licenseNumber)
        try container.encode(issuingOrganization, forKey: .issuingOrganization)
        try container.encode(expiryDate, forKey: .expiryDate)
        
        try container.encode(description, forKey: .description)
        try container.encode(yearsOfExperience, forKey: .yearsOfExperience)
    }
}
