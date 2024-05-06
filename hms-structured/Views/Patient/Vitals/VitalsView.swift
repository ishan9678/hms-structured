//
//  VitalsView.swift
//  hms-structured
//
//  Created by Ishan on 03/05/24.
//

import SwiftUI
import HealthKit
import Charts

struct VitalsView: View {
    @EnvironmentObject var healthStore: HKHealthStore
    @State var heartRates: [(Double, Date)] = []
    @State var bloodPressureSystolic: String
    @State var bloodPressureDiastolic: String
    @State var spo2: String
    @State var bodyTemp: String
    @State var bloodGlucose: String
    @State private var heartRateSamples: [Double] = []
    @State var bmi : String


    
    var body: some View {
        VStack {
            
            Text("Body Vitals")
                .font(.largeTitle)
            
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)){
                HealthCardView(image: Image(systemName: "figure"), title: "BMI", subTitle: bmi)
                    .frame(width: 210, height: 120)
                HealthCardView(image: Image(systemName: "drop.fill"), title: "Blood Type", subTitle: "O+" )
                    .frame(width: 210, height: 120)
                HealthCardView(image: Image(systemName: "waveform.path.ecg"), title: "Blood Pressure", subTitle: bloodPressureSystolic + "/" + bloodPressureDiastolic + " mmHg")
                    .frame(width: 210, height: 120)
                HealthCardView(image: Image(systemName: "percent"), title: "Spo2", subTitle: spo2 + " %")
                    .frame(width: 210, height: 120)
                HealthCardView(image: Image(systemName: "thermometer.variable.and.figure"), title: "Body Temp", subTitle: bodyTemp + " C")
                    .frame(width: 210, height: 120)
                HealthCardView(image: Image(systemName: "drop.fill"), title: "Blood Glucose", subTitle: bodyTemp + " mg/dl")
                    .frame(width: 210, height: 120)
        
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                    HStack(alignment: .bottom) {
                        Text("\(String(format: "%.2f", heartRates.last?.0 ?? 0))")
                            .font(.system(size: 26))
                            
                        Text("BPM")
                            .font(.caption)
                            .baselineOffset(2)
                    }
                    Image("Heart")
                }

                Spacer()
                Chart {
                    ForEach(heartRates.indices, id: \.self) { index in
                        BarMark(x: PlottableValue.value("Hours", formatTimestamp(heartRates[index].1)), y: PlottableValue.value("X", Int(heartRates[index].0)))
                
                    }

                }.frame(width: 200, height: 100)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)

        }
        .padding()
        .onAppear(){
            readHealthData()
        }
    }
    private func formatTimestamp(_ timestamp: Date) -> Int {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let hour = Int(dateFormatter.string(from: timestamp)) ?? 0
        return hour
    }


    //MARK: - Read health data
    
    
    private func readHealthData(){
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let spo2Type = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        let bloodPressureType = HKObjectType.correlationType(forIdentifier: .bloodPressure)!
        let bodyTemperatureType = HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        let bloodGlucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        let bmiType = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        let pulseOximetryType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        let ecgType = HKObjectType.electrocardiogramType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(
            sampleType: heartRateType,
            predicate: get24hPredicate(),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (query, results, error) in
                guard let samples = results as? [HKQuantitySample] else {
                    print(error!)
                    return
                }
                for sample in samples {
                    let mSample = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    let timestamp = sample.startDate
                    print("Heart rate : \(mSample) at \(timestamp)")
                    self.heartRates.append((mSample, timestamp)) // Append heart rate and timestamp to the array
                }
        })
        
        let spo2Query = HKSampleQuery.init(sampleType: spo2Type,
                                            predicate: get24hPredicate(),
                                            limit: HKObjectQueryNoLimit,
                                            sortDescriptors: [sortDescriptor],
                                            resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
                print("SpO2 : \(mSample)")
                self.spo2 = String(mSample)
            }
        })
        
        let bloodPressureQuery = HKSampleQuery(
            sampleType: bloodPressureType,
            predicate: get24hPredicate(),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (query, results, error) in
                guard let correlationSamples = results as? [HKCorrelation] else {
                    print("Failed to fetch blood pressure samples: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for correlation in correlationSamples {
                    let systolicSamples = correlation.objects(for: HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!)
                    let diastolicSamples = correlation.objects(for: HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!)

                    if let systolicSample = systolicSamples.first as? HKQuantitySample,
                       let diastolicSample = diastolicSamples.first as? HKQuantitySample {
                        let systolicValue = Int(systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                        let diastolicValue = Int(diastolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury()))
                        print("Blood Pressure - Systolic: \(systolicValue), Diastolic: \(diastolicValue)")
                        self.bloodPressureDiastolic = "\(diastolicValue)"
                        self.bloodPressureSystolic = "\(systolicValue)"

                    }
                }
            })


        
        let bodyTemperatureQuery = HKSampleQuery.init(sampleType: bodyTemperatureType,
                                                      predicate: get24hPredicate(),
                                                      limit: HKObjectQueryNoLimit,
                                                      sortDescriptors: [sortDescriptor],
                                                      resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
                print("Body Temperature : \(mSample)")
                self.bodyTemp = String(mSample)
            }
        })
        
        let bloodGlucoseQuery = HKSampleQuery.init(sampleType: bloodGlucoseType,
                                                   predicate: get24hPredicate(),
                                                   limit: HKObjectQueryNoLimit,
                                                   sortDescriptors: [sortDescriptor],
                                                   resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit(from: "mg/dL"))
                print("Blood Glucose : \(mSample)")
                self.bloodGlucose = String(mSample)
            }
        })
        
        let bmiQuery = HKSampleQuery.init(sampleType: bmiType,
                                          predicate: nil,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: [sortDescriptor],
                                          resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit.count())
                print("BMI : \(mSample)")
                self.bmi = String(mSample)
            }
        })
        
        let pulseOximetryQuery = HKSampleQuery.init(sampleType: pulseOximetryType,
                                                    predicate: get24hPredicate(),
                                                    limit: HKObjectQueryNoLimit,
                                                    sortDescriptors: [sortDescriptor],
                                                    resultsHandler: { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit.percent())
                print("Pulse Oximetry : \(mSample)")
            }
        })
        
        self.healthStore.execute(spo2Query)
        self.healthStore.execute(bloodPressureQuery)
        self.healthStore.execute(bodyTemperatureQuery)
        self.healthStore.execute(bloodGlucoseQuery)
        self.healthStore.execute(bmiQuery)
        self.healthStore.execute(pulseOximetryQuery)
        self.healthStore.execute(sampleQuery)
    }

    private func get24hPredicate() ->  NSPredicate{
        let today = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: today)
        let predicate = HKQuery.predicateForSamples(withStart: startDate,end: today,options: [])
        return predicate
    }
}



#Preview {
    VitalsView(bloodPressureSystolic: "", bloodPressureDiastolic: "", spo2: "", bodyTemp: "", bloodGlucose: "", bmi: "")
}
