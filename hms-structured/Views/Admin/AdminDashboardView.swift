//
//  AdminDashboardView.swift
//  hms
//
//  Created by Divyanshu Pabia on 02/05/24.
//

import SwiftUI
import Charts
import Firebase


struct AdminDashboardView: View {
    
    @State private var selectedChartType = "Bar"
    @ObservedObject var viewModel = PatientFrequencyViewModel()
    @AppStorage("log_status") var logStatus:Bool = false
    @AppStorage("role") var role:String = ""
    var body: some View {
        NavigationView {
            VStack {
                // Title and Notification
                HStack {
                    Text("Hello, Admin")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .padding([.top, .bottom], 16)
                        .padding()
                        .foregroundColor(viewModel.emergencyColor.contrastingColor())
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
                    .foregroundColor(viewModel.emergencyColor.contrastingColor())
                    
                    Button(action: {
                                            do {
                                                logStatus = false
                                                role = ""
                                                try Auth.auth().signOut()
                                                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                                                // Update to switch views properly
                                                if let window = UIApplication.shared.windows.first {
                                                    window.rootViewController = UIHostingController(rootView: LoginView())
                                                    window.makeKeyAndVisible()
                                                }
                                            } catch {
                                                print("Error signing out: \(error.localizedDescription)")
                                            }
                                        }) {
                                            Image(systemName: "arrow.right.square")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(viewModel.emergencyColor.contrastingColor())
                                        }
                                        .padding()
                }
                .background(viewModel.emergencyColor)  // Set background color to blue
                .foregroundColor(.white)  // Change text color to white for better contrast
                
                // Information Components
                ScrollView {
                    VStack(spacing: 20) {
                        StatisticsGridView(stats: [
                            ("Total Patients", String(viewModel.totalPatients)),
                            ("Total Doctors", String(viewModel.totalDoctors)),
                            ("Appointments", String(viewModel.totalAppointments)),
                            ("Total Records", String(viewModel.totalMedicalTests))
                        ], backgroundColor: viewModel.emergencyColor)
                        
                        Picker("Select Chart Type", selection: $selectedChartType) {
                                            Text("Bar").tag("Bar")
                                            Text("Line").tag("Line")
                                            Text("Area").tag("Area")
                                        }
                        .pickerStyle(.segmented)
                                        .padding()
                        
                        VStack(spacing: 20) {
                                                switch selectedChartType {
                                                case "Line":
                                                    LineChartView(data: viewModel.patientFrequency, color: viewModel.emergencyColor)
                                                case "Area":
                                                    AreaChartView(data: viewModel.patientFrequency, color: viewModel.emergencyColor)
                                                default:
                                                    BarChartView(data: viewModel.patientFrequency, color: viewModel.emergencyColor)
                                                }
                                            }
                    }
                }
                .refreshable {
                    viewModel.fetchBookings()
                    viewModel.fetchTotalPatients()
                    viewModel.fetchTotalDoctors()
                    viewModel.fetchTotalAppointments()
                    viewModel.fetchTotalMedicalTests()
                    viewModel.fetchEmergencyColor()
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
            viewModel.fetchTotalMedicalTests()
            viewModel.fetchEmergencyColor()
        }
    }
}
struct StatisticsGridView: View {
    var stats: [(String, String)]
    var backgroundColor: Color  // Add this to receive color

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(stats, id: \.0) { stat in
                InfoComponent(title: stat.0, value: stat.1, backgroundColor: backgroundColor)
            }
        }
        .padding(.horizontal)
    }
}

struct BarChartView: View {
    var data: [String: Int]
    var color: Color

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                BarMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
                .foregroundStyle(color)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

struct LineChartView: View {
    var data: [String: Int]
    var color: Color

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                LineMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
                .symbol(Circle())
                .foregroundStyle(color)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

struct AreaChartView: View {
    var data: [String: Int]
    var color: Color
    
    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { key in
                AreaMark(
                    x: .value("Day", key),
                    y: .value("Patients", data[key]!)
                )
                .foregroundStyle(color)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

struct InfoComponent: View {
    var title: String
    var value: String
    var backgroundColor: Color

    var body: some View {
        VStack(alignment: .center) {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(backgroundColor.contrastingColor())
            Text(title)
                .font(.body)
                .foregroundColor(backgroundColor.contrastingColor())
        }
        .padding()
        .frame(minWidth: 110, maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
    }
}

extension Color {
    func contrastingColor() -> Color {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        let c = UIColor(self)
        c.getRed(&r, green: &g, blue: &b, alpha: nil)
        return (r * 0.299 + g * 0.587 + b * 0.114) > 0.5 ? .black : .white
    }
}

#Preview {
    AdminDashboardView()
}

