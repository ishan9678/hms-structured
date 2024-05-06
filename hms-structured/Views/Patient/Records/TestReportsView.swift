//
//  TestReportsView.swift
//  hms-structured
//
//  Created by SHHH!! private on 03/05/24.
//
import SwiftUI


struct Report: Identifiable {
    let id = UUID()
    let testName: String
    let date: String
    let time: String
    let doctorName: String
    let image: String
    let imageURL: String// Assuming imageURL is the URL of the image in Firebase Storage
    let doctorDepartment: String
}

struct ReportRow: View {
    let report: Report
    
    var body: some View {
        HStack {
            if (report.testName=="Blood Test"){
                Image("blood")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            }else if(report.testName=="X-Ray") {
                Image("Xray")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            }else if(report.testName == "Biopsy") {
                Image("Biopsy")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            }else{
                Image("Mri")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            }
            Text(report.testName)
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}

struct ReportsView: View {
    @State private var selectedReport: Report?
    @State private var isSheetPresented = false
    @State private var searchText = ""
    
    let reports = [
        Report(testName: "Blood Test", date: "April 22, 2024", time: "10:00 AM", doctorName: "Dr. John Doe",image:"" , imageURL: "https://example.com/image.jpg",doctorDepartment:"anesthesia"),
        Report(testName: "X-Ray", date: "April 22, 2024", time: "11:00 AM", doctorName: "Dr. Jane Smith", image:"",imageURL: "https://example.com/image.jpg",doctorDepartment:"orthopedics"),
        Report(testName: "MRI", date: "April 23, 2024", time: "11:00 AM", doctorName: "Dr. Jane Smith", image:"",imageURL: "https://example.com/image.jpg",doctorDepartment:"orthopedics"),
        Report(testName: "Biopsy", date: "April 23, 2024", time: "11:00 AM", doctorName: "Dr. Jane Smith", image:"",imageURL: "",doctorDepartment:"general medicine"),
        // Add more reports as needed
    ]
    
    var filteredReports: [Report] {
        if searchText.isEmpty {
            return reports
        } else {
            return reports.filter { $0.testName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredReports) { report in
                NavigationLink(destination: ReportDetailSheet(report: report, isPresented: $isSheetPresented)) {
                    ReportRow(report: report)
                }
            }
            .searchable(text: $searchText)
        }
    }
}


struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}

struct ReportDetailSheet: View {
    let report: Report
    @Binding var isPresented: Bool
    @State private var pdfDownloaded = false // State to track if PDF is downloaded
    @State private var downloadError = false // State to track download error

    var body: some View {
        VStack {
            if (report.testName == "Blood Test") {
                Image("blood")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .aspectRatio(contentMode: .fit)
            } else if (report.testName == "X-Ray") {
                Image("Xray")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .aspectRatio(contentMode: .fit)
            } else if(report.testName == "MRI") {
                Image("Mri")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .aspectRatio(contentMode: .fit)
            }else if(report.testName == "Biopsy") {
                Image("Biopsy")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .aspectRatio(contentMode: .fit)
            }

            
            Text(report.testName)
                .font(.title)
                .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(radius: 4)
                    .frame(width: 360, height: 200)
                
                VStack(spacing: 40) {
                    HStack(spacing: 120) {
                        VStack {
                            Text("Time")
                                .fontWeight(.bold)
                            Text("\(report.time)")
                        }
                        VStack {
                            Text("Date")
                                .fontWeight(.bold)
                            Text("\(report.date)")
                        }
                    }
                    HStack(spacing: 120) {
                        VStack {
                            Text("Name")
                                .fontWeight(.bold)
                            Text("\(report.doctorName)")
                        }
                        VStack {
                            Text("Department")
                                .fontWeight(.bold)
                            Text("\(report.doctorDepartment)")
                        }
                    }
                }
            }
            
            Text("Report for \(report.testName):")
                .font(.headline)
                .padding(.top)
            
            Text("Details for \(report.testName)")
                .padding()
            Button(action: {
                            downloadPDF()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Download PDF")
                            }
                            .padding(20)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        .alert(isPresented: $pdfDownloaded) {
                            // Alert for successful download
                            Alert(
                                title: Text("PDF Downloaded"),
                                message: Text("The PDF has been downloaded successfully!"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .alert(isPresented: $downloadError) {
                            // Alert for download error
                            Alert(
                                title: Text("Error"),
                                message: Text("Failed to download the PDF."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                }

    @MainActor func downloadPDF() {
                    let url = render() // Generate the PDF
                    
                    // Check if the file was successfully generated
                    if FileManager.default.fileExists(atPath: url.path) {
                        do {
                            // Specify the destination URL in the simulator's file folder
                            let destinationURL = URL(fileURLWithPath: "/Users/shhhprivate/Desktop/Reports.pdf")
                            
                            // Copy the generated PDF file to the destination URL
                            try FileManager.default.copyItem(at: url, to: destinationURL)
                            
                            // Set the flag to show the alert for successful download
                            pdfDownloaded = true
                        } catch {
                            // Set the flag to show the alert for download error
                            downloadError = true
                            print("Error downloading PDF: \(error)")
                        }
                    } else {
                        // Set the flag to show the alert for download error
                        downloadError = true
                        print("PDF file not found at \(url)")
                    }
                }

    @MainActor func render() -> URL {
                    // Render the report to a PDF file
                    // This function should generate the PDF content based on the report
                    // For demonstration purposes, I'll just create a simple PDF with "Hello, world!" text
                    
                    // 1: Render Hello World with some modifiers
                    let renderer = ImageRenderer(content:
                        Text("Hello, world!")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.blue)
                            .clipShape(Capsule())
                    )

                    // 2: Save it to a temporary directory
                    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.pdf")

                    // 3: Start the rendering process
                    renderer.render { size, context in
                        // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
                        var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)

                        // 5: Create the CGContext for our PDF pages
                        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                            return
                        }

                        // 6: Start a new PDF page
                        pdf.beginPDFPage(nil)

                        // 7: Render the SwiftUI view data onto the page
                        context(pdf)

                        // 8: End the page and close the file
                        pdf.endPDFPage()
                        pdf.closePDF()
                    }

                    return url
                }
            }


#Preview {
    ReportDetailSheet(report: Report(testName: "Blood Test", date: "April 22, 2024", time: "10:00 AM", doctorName: "Dr. John Doe", image: "Cardiology",imageURL: "",doctorDepartment: "Orthodpedics"), isPresented: .constant(true))
}

