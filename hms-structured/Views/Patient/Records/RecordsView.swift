//
//  RecordsView.swift
//  hms-structured
//
//  Created by SHHH!! private on 03/05/24.
//

import SwiftUI

struct RecordsView: View {
    // Define your segments
    let segments = ["Prescription", "Reports"]
    
    // State variable to hold the selected segment
    @State private var selectedSegmentIndex = 0
    @State private var searchText = "" // State variable to hold the search text
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                Picker(selection: $selectedSegmentIndex, label: Text("Select Segment")) {
                    ForEach(0..<segments.count) { index in
                        Text(self.segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedSegmentIndex == 0 { // Show the prescription list and search bar
                    SearchablePrescriptionListView(searchText: $searchText)
                } else if selectedSegmentIndex == 1 { // Show ReportsView
                    ReportsView(patientID: userUID, searchText: $searchText)
                }
            }
            .navigationBarTitle("Your Records")
            .padding()
        }
        .searchable(text: $searchText)
    }
}


struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}
