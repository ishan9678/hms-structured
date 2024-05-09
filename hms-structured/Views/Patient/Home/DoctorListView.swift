//
//  DoctorCardList.swift
//  HMS-Team 5
//
//  Created by Ishan on 22/04/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct DoctorCardList: View {
    @ObservedObject var doctorsViewModel = DoctorsViewModel()
    @State private var selectedDoctor: Doctor?
    
    var body: some View {
        VStack {
            HStack {
                Text("Top Doctors")
                    .padding(.leading, 25)
                    .font(.headline)
                Spacer()
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(doctorsViewModel.doctors, id: \.id) { doctor in
                            VStack(alignment: .center) {
                                if let imageUrl = URL(string: doctor.profileImageURL) {
                                    
                                    NavigationLink {
                                        DoctorDetailsView(doctor: doctor)
                                    } label: {
                                        WebImage(url: imageUrl)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 110, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
                                    }
                                } else {
                                    // Handle invalid URL
                                    Text("Invalid URL")
                                        .foregroundColor(.red)
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(doctor.fullName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(doctor.department)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom)
                            }
//                            .padding(.top, 10)
                            .onTapGesture {
                                selectedDoctor = doctor
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    doctorsViewModel.fetchDoctors()
                }
            }
        }
    }
    
    struct DoctorCardList_Previews: PreviewProvider {
        static var previews: some View {
            DoctorCardList()
        }
    }

