//
//  AdminDashboardView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import SwiftUI
import Charts

struct AdminDashboardView: View {
    let code = "Black"
    
    @State private var selectedChartType = "Bar"
    @ObservedObject var viewModel = PatientFrequencyViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Title and Notification
                HStack {
                    Text("Hello, Admin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.top, .bottom], 16)
                        .padding()
                    Spacer()
                    Button(action: {
                        print("Notifications tapped")
                    }) {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                }
                .background(Color.bgColor1)  // Set background color to blue
                .foregroundColor(.white)  // Change text color to white for better contrast
                
                // Information Components
                ScrollView {
                    VStack(spacing: 20) {
                        StatisticsGridView(stats: [
                                                    ("Total Patients", String(viewModel.totalPatients)),
                                                    ("Total Doctors", String(viewModel.totalDoctors)),
                                                    ("Appointments", String(viewModel.totalAppointments)),
                                                    ("Code", code)
                                                ])
                        
                        Picker("Select Chart Type", selection: $selectedChartType) {
                                            Text("Bar").tag("Bar")
                                            Text("Line").tag("Line")
                                            Text("Area").tag("Area")
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                        
                        VStack(spacing: 20) {
                                                switch selectedChartType {
                                                case "Line":
                                                    LineChartView(data: viewModel.patientFrequency)
                                                case "Area":
                                                    AreaChartView(data: viewModel.patientFrequency)
                                                default:
                                                    BarChartView(data: viewModel.patientFrequency)
                                                }
                                            }
                    }
                }
                Spacer()
            }
            .navigationTitle("Dashboard")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.fetchBookings()
            viewModel.fetchTotalPatients()
            viewModel.fetchTotalDoctors()
            viewModel.fetchTotalAppointments()
        }
    }
}
struct StatisticsGridView: View {
    var stats: [(String, String)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(stats, id: \.0) { stat in
                InfoComponent(title: stat.0, value: stat.1)
            }
        }
        .padding(.horizontal)
    }
}

struct BarChartView: View {
    var data: [String: Int]

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                BarMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
                .annotation(position: .top) {
                    Text("\(data[key]!)")
                }
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
        
    }
}

struct LineChartView: View {
    var data: [String: Int]

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                LineMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
                .symbol(Circle())
                .foregroundStyle(Color.bgColor1)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

struct AreaChartView: View {
    var data: [String: Int]

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                AreaMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

struct InfoComponent: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .center) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    AdminDashboardView()
}
