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
    
    var body: some View {
        VStack{
            HStack {
                Text("Find your doctor")
                    .padding(.leading, 25)
                    .font(.headline)
                Spacer()
                Button("See all") {}
                    .padding(.trailing, 25)
                    .font(.headline)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(doctorsViewModel.doctors, id: \.id) { doctor in
                        VStack(alignment: .center) {
                            if let imageUrl = URL(string: doctor.profileImageURL) {
                                WebImage(url: imageUrl)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 130, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
                            } else {
                                // Handle invalid URL
                                Text("Invalid URL")
                                    .foregroundColor(.red)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(doctor.fullName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(doctor.department)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom)
                        }
                        .padding(.top,10)
                    }

                }
                .padding(.horizontal)
            }
            .onAppear {
                doctorsViewModel.fetchDoctors()
                print(doctorsViewModel.fetchDoctors())
            }
        }
    }
}


struct DoctorCardList_Previews: PreviewProvider {
    static var previews: some View {
        DoctorCardList()
    }
}


