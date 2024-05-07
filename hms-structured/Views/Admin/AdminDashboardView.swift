//
//  AdminDashboardView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import SwiftUI
import Charts

struct AdminDashboardView: View {
    // Static data for demonstration
    let totalPatients = 150
    let totalDoctors = 25
    let totalAppointmentsToday = 40
    let patientFrequency: [String: Int] = ["Mon": 10, "Tue": 20, "Wed": 15, "Thu": 25, "Fri": 18, "Sat": 10, "Sun": 12]
    
    var body: some View {
        NavigationView {
            VStack {
                // Title and Notification
                HStack {
                    Text("Hello, Admin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    Button(action: {
                        print("Notifications tapped")
                    }) {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                }
                
                // Information Components
                ScrollView {
                    VStack(spacing: 20) {
                        InfoComponent(title: "Total Patients", value: String(totalPatients))
                        InfoComponent(title: "Total Doctors", value: String(totalDoctors))
                        InfoComponent(title: "Appointments Today", value: String(totalAppointmentsToday))
                        
                        // Bar Graph for Patient Frequency
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Patient Frequency This Week")
                                .font(.headline)
                                .padding(.leading)
                            Chart {
                                ForEach(Array(patientFrequency.keys), id: \.self) { key in
                                    BarMark(
                                        x: .value("Day", key),
                                        y: .value("Patients", patientFrequency[key]!)
                                    )
                                }
                            }
                            .frame(height: 300)
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("Dashboard")
            .navigationBarHidden(true)
        }
    }
}

struct InfoComponent: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    AdminDashboardView()
}
