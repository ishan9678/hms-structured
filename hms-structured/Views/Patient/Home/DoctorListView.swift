//
//  DoctorCardList.swift
//  HMS-Team 5
//
//  Created by Ishan on 22/04/24.
//

import SwiftUI

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
                        VStack(alignment: .leading) {
                            Text(doctor.fullName)
                                .font(.headline)
                                .frame(width: 130, height: 130)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            Text(doctor.department)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
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


