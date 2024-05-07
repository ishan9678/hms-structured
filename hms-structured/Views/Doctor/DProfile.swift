//
//  DProfile.swift
//  Reports
//
//  Created by Ashi Gupta on 07/05/24.
//


import SwiftUI

struct DProfile: View {
    @State private var appointmentsSchedule: Int? = 10 // Dummy number of appointments
    @State private var hours: Int? = 5 // Dummy number of hours

    var body: some View {
        ScrollView{
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.bgColor1)
                    .frame(width: 400, height: 500)
                    .overlay(
                        VStack {
                            Image("doctor") // Replace "doctor_image" with the name of your doctor image asset
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .padding(.top, 80)
                                .padding(.bottom, 0)
                            VStack{
                                Text("Dr. Alia Mukherjee")
                                    .foregroundColor(.white)
                                    .padding(.top,10)
                                Text("Upcoming Tasks")
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                                    .padding(.top,40)
                                
                                
                            }
                            
                            HStack(spacing: 2) {
                                VStack {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                   
                                    if let appointmentsSchedule = appointmentsSchedule {
                                        Text("\(appointmentsSchedule) appointments")
                                            .foregroundColor(.white)
                                    }
                                    Text("Scheduled")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing,110)
                                
                                VStack {
                                    Color.white
                                        .frame(width: 30, height: 30) // Background color
                                        .mask(
                                            Image("clock")
                                                .resizable()
                                        )
                                   
                                    if let hours = hours {
                                        Text("\(hours) hrs")
                                            .foregroundColor(.white)
                                    }
                                    Text("Work")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top,20)
                        }
                    )
                    .padding(.top,-60)
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .padding(.top,350)
                    .overlay(
                        VStack {
                            HStack {
                                Image("settings")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Account Settings")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            
                            Divider()
                            
                            HStack {
                                Image("padlock")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Change Password")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            Divider()
                            HStack {
                                Image("docs")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Terms and Conditions")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            Divider()
                            HStack {
                                Image("patients")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Patients Info")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            Divider()
                            HStack {
                                Image("info")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Log Out")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                    )
            }
        }
    }
}

struct DProfile_Previews: PreviewProvider {
    static var previews: some View {
        DProfile()
    }
}
