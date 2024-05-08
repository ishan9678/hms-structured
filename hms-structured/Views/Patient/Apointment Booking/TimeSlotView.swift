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
    let availabilityCount: Int
    let onTap: (String) -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(slotColor)
            .frame(width: 140, height: 50)
            .overlay(
                Text(time)
                    .foregroundColor(slotTextColor)
            )
            .onTapGesture {
                if availabilityCount < 3 {
                    onTap(time)
                }
            }
            .shadow(radius: 1)
    }

    var slotColor: Color {
        switch availabilityCount {
        case 0:
            return isSelected ? .blue : Color("fully-available")
        case 1:
            return isSelected ? .blue : Color("limited-availability")
        case 2:
            return isSelected ? .blue : Color("almost-full")
        default:
            return isSelected ? .blue : .gray
        }
    }

    var slotTextColor: Color {
        isSelected ? .white : .black
    }
}
