//
//  DoctorPatientRecordView.swift
//  hms-structured
//
//  Created by srijan mishra on 08/05/24.
//

import SwiftUI

struct DoctorDashboard: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("Select")) {
                Text("Prescription").tag(0)
                Text("Tests").tag(1)
                Text("Vitals").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedTab == 0 {
                PrescriptionPage(doctor: <#AppointedDoctor#>)
            } else if selectedTab == 1 {
                TestsPage(report: <#Report#>)
            } else if selectedTab == 2 {
                VitalsPage()
            }
        }
    }
}

struct PrescriptionPage: View {
    let doctor: AppointedDoctor
    var body: some View {
        VStack {
            Button(action: {
                // Navigate to PrescriptionForm page
            }) {
                Text("Add Prescription")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            PrescriptionView(doctor: <#AppointedDoctor#>) // Call PrescriptionRow function
        }
    }
}

struct TestsPage: View {
    let report: Report
    var body: some View {
        ReportRow(report: report) // Call ReportRow function
    }
}

struct VitalsPage: View {
    var body: some View {
        VitalsView(bloodPressureSystolic: "", bloodPressureDiastolic: "", spo2: "", bodyTemp: "", bloodGlucose: "", bmi: "") // Call VitalsView function
    }
}

struct DoctorDashboard_Previews: PreviewProvider {
    static var previews: some View {
        DoctorDashboard()
    }
}
