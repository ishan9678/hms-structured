//
//  hms_structuredApp.swift
//  hms-structured
//
//  Created by Ishan on 25/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import HealthKit


@main
struct hms_structuredApp: App {
    
    private let healthStore: HKHealthStore
    
    init() {
        FirebaseApp.configure()
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("This app requires a device that supports HealthKit")
        }
        healthStore = HKHealthStore()
        requestHealthkitPermissions()
    }
    
    private func requestHealthkitPermissions() {
        let sampleTypesToRead: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.electrocardiogramType(),
        ]
        guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else {
            fatalError("*** This method should never fail ***")
        }
        print("after ackes")
        print (sampleType)
        healthStore.requestAuthorization(toShare: nil, read: sampleTypesToRead) { (success, error) in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
                return
            }

            if success {
                print("Authorization granted")
            } else {
                print("Authorization denied")
            }
        }
    }
    
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(healthStore)
        }
    }
}

extension HKHealthStore: ObservableObject{}
