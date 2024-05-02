//
//  ContentView.swift
//  hms-structured
//
//  Created by Ishan on 25/04/24.
//

import SwiftUI


struct ContentView: View {
    
    var body: some View {
        TabView{
            PatientHomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            DoctorHomeView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Record")
                }
            BookAppointmentView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Book")
                }
            DoctorHomeView()
                .tabItem {
                    Image(systemName: "staroflife")
                    Text("Vital")
                }
            DoctorHomeView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

