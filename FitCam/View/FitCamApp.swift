//
//  FitCamApp.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI
import HealthKit

@available(iOS 16.0, *)
@main
struct FitCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate2
    let realmWrapper = RealmWrapper()
    @State var isWorkoutSelected: Bool = false
    @State private var isAuthorizationRequested = false // New state variable
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(isWorkoutSelected: $isWorkoutSelected)
                    .environmentObject(realmWrapper)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartCamera"))) { _ in
                        self.isWorkoutSelected = true
                    }
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StartRecording"), object: nil, queue: nil) { _ in
                    // Handle StartRecording notification if needed
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StopRecording"), object: nil, queue: nil) { _ in
                    // Handle StopRecording notification if needed
                }
                
                checkAuthorizationStatus()
            }
        }
    }
    
    private func typesToShare() -> Set<HKSampleType> {
        return [HKObjectType.workoutType()]
    }
    
    private func typesToRead() -> Set<HKObjectType> {
        return [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)!,
            HKObjectType.activitySummaryType()
        ]
    }
    
    private func checkAuthorizationStatus() {
        let healthStore = HKHealthStore()
        let typesToRead: Set<HKObjectType> = typesToRead()
        let typesToShare: Set<HKSampleType> = typesToShare()

        healthStore.getRequestStatusForAuthorization(toShare: typesToShare, read: typesToRead) { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    fatalError("Authorization status request failed: \(error.localizedDescription)")
                } else {
                    if status == .shouldRequest {
                        requestAuthorization(typesToShare: typesToShare, typesToRead: typesToRead)
                    } else {
                        isAuthorizationRequested = true
                    }
                }
            }
        }
    }
    
     func requestAuthorization(typesToShare: Set<HKSampleType>, typesToRead: Set<HKObjectType>) {
        let healthStore = HKHealthStore()
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    fatalError("Authorization request failed: \(error.localizedDescription)")
                } else {
                    isAuthorizationRequested = true
                }
            }
        }
    }
}



