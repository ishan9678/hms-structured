//
//  AdminTabBarView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import SwiftUI

struct AdminTabBarView: View {
    var body: some View {
        TabView {
            AdminDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            AdminDoctorCardList()
                .tabItem {
                    Label("Staff", systemImage: "person.3")
                }

            AppointmentsAdminView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }

            AdminReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.text")
                }

            EmergencyView()
                .tabItem {
                    Label("Emergency", systemImage: "exclamationmark.triangle")
                }
        }
    }
}

#Preview {
    AdminTabBarView()
}
