//
//  ContentView.swift
//  hms-structured
//
//  Created by Ishan on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus:Bool = false
    @AppStorage("role") var role:String = ""
    var body: some View {
        NavigationView {
            if(logStatus){
                if(role == "doctor"){
                    DoctorHomeView()
                }
                else if(role == "patient"){
                    PatientContentView()
                }
                else if(role == "admin"){
                    AdminTabBarView()
                }
            }
            else{
                OnBoardingScreen()
            }
        }
    }
}

#Preview {
    ContentView()
}
