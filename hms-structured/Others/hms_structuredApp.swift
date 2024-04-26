//
//  hms_structuredApp.swift
//  hms-structured
//
//  Created by Ishan on 25/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth


@main
struct hms_structuredApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
    }
}
