//
//  TimeSlotView.swift
//  hms-structured
//
//  Created by Ishan on 26/04/24.
//

import SwiftUI

struct TimeSlotView: View {
    let time: String
    let isSelected: Bool
    let onTap: (String) -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? Color.blue : Color.white)
            .frame(width: 140, height: 50)
            .overlay(
                Text(time)
                    .foregroundColor(isSelected ? .white : .black)
            )
            .onTapGesture {
                onTap(time)
            }
            .shadow(radius: 1)
    }
}


