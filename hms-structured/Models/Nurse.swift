//
//  Nurse.swift
//  hms
//
//  Created by Divyanshu Pabia on 30/04/24.
//

import Foundation
import SwiftUI

class Nurse: ObservableObject, Identifiable, Codable {
    @Published var profileImageURL: String?
    
    @Published var fullName: String
    @Published var gender: String
    @Published var dateOfBirth: Date
    @Published var email: String
    @Published var phone: String
    @Published var emergencyContact: String
    
    @Published var employeeID: String
    @Published var department: String
    @Published var position: String
    @Published var startDate: Date

    @Published var description: String
    @Published var yearsOfExperience: String

    enum CodingKeys: String, CodingKey {
        case profileImageURL
        case fullName, gender, dateOfBirth, email, phone, emergencyContact
        case employeeID, department, position, startDate
        case description, yearsOfExperience
    }
    
    init(profileImageURL: String? = nil, fullName: String, gender: String, dateOfBirth: Date, email: String, phone: String,
         emergencyContact: String, employeeID: String, department: String, position: String,
         startDate: Date, description: String, yearsOfExperience: String) {
        self.profileImageURL = profileImageURL
        self.fullName = fullName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.phone = phone
        self.emergencyContact = emergencyContact
        self.employeeID = employeeID
        self.department = department
        self.position = position
        self.startDate = startDate
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
        self.position = try container.decode(String.self, forKey: .position)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        
        self.description = try container.decode(String.self, forKey: .description)
        self.yearsOfExperience = try container.decode(String.self, forKey: .yearsOfExperience)
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
        try container.encode(position, forKey: .position)
        try container.encode(startDate, forKey: .startDate)
        
        try container.encode(description, forKey: .description)
        try container.encode(yearsOfExperience, forKey: .yearsOfExperience)
    }
}

