//
//  Profile.swift
//  Reports
//
//  Created by Ashi Gupta on 06/05/24.
//

import SwiftUI

struct Profile: View {
    @State private var heartRate: Int? = 215
    @State private var height: Int? = 180
    @State private var weight: Int? = 82
    
    var body: some View {
        ScrollView{
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.blue)
                    .frame(width: 400, height: 400)
                //                .padding()
                    .overlay(
                        VStack {
                            Image("doctor") // Replace "doctor_image" with the name of your doctor image asset
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            
                            //                            .padding(.top, 20)
                            
                            // Doctor's Name could be added here if you want it back
                            Text("Lakshami Awasthi")
                                .foregroundColor(.white)
                            HStack(spacing: 20) {
                                VStack {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                    Text("Heart rate")
                                        .foregroundColor(.white)
                                    if let heartRate = heartRate {
                                        Text("\(heartRate) bpm")
                                            .foregroundColor(.white)
                                    }
                                }
                                //                            padding(.trailing,2)
                                VStack {
                                    Color.white
                                        .frame(width: 30, height: 30) // Background color
                                        .mask(
                                            Image("height")
                                                .resizable()
                                        )
                                    Text("Height")
                                        .foregroundColor(.white)
                                    if let height = height {
                                        Text("\(height) cm")
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                
                                VStack {
                                    Color.white
                                        .frame(width: 30, height: 30) // Background color
                                        .mask(
                                            Image("weight")
                                                .resizable()
                                        )
                                    Text("Weight")
                                        .foregroundColor(.white)
                                    if let weight = weight {
                                        Text("\(weight) kg")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.top,80)
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
                            
                            Divider() // Add a divider between the HStacks
                            
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

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
