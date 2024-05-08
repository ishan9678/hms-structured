//
//  PatientContentView.swift
//  hms-structured
//
//  Created by srijan mishra on 02/05/24.
//

import SwiftUI

struct PatientContentView: View {
    var body: some View {
        TabView{
            PatientHomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            RecordsView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Record")
                }
            BookAppointmentView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Book")
                }
            VitalsView(bloodPressureSystolic: "", bloodPressureDiastolic: "", spo2: "", bodyTemp: "", bloodGlucose: "", bmi: "")
                .tabItem {
                    Image(systemName: "staroflife")
                    Text("Vital")
                }
            Profile()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PatientContentView()
    }
}
