//
//  WorkoutManager.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/28/22.
//

import Foundation
import HealthKit
import SwiftUI
import RealmSwift
import WatchConnectivity


class WorkoutManager: NSObject, ObservableObject {
    
    var timer = Timer()
    let realm = try! Realm()
    var savedWorkout:SavedWorkout!
    var selectedWorkout: HKWorkoutActivityType? {
    
    didSet {
        guard let selectedWorkout = selectedWorkout else {
            return
        }
        
//        startSampler()
        
    }
    }
    func sendTest() {
        if WCSession.isSupported() {
            let session = WCSession.default
            
            session.sendMessage((["request":"workoutSelected"])) { response in
                print("received Reply \(response)")
            }

        }
            }
    //MARK: - Sampler Setup
    
    func startSampler() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.sampleWorkoutData()
        })



        savedWorkout = SavedWorkout()
        savedWorkout.date = Date().formatted(date: .abbreviated, time: .standard)
        savedWorkout.workoutType = selectedWorkout?.name ?? ""
        
        do {
            try realm.write({
//                realm.add(savedWorkout)
            })
        }
        catch {
         print("error saving workout from sampler start")
        }
        
    }
    func stopSampler() {
        timer.invalidate()
    }
    
    func writeWorkoutToDatabase() {
        
        do {
            try realm.write {
                realm.add(savedWorkout)
            }
        }
        catch {
            print("")
        }
    }
    
    var samplerCount = 0
    
    func sampleWorkoutData() {
        var date = Date().formatted(date: .abbreviated, time: .omitted)
        var time = Date().formatted(date: .omitted, time: .standard)
        var datapoint = Datapoint()
        
        switch selectedWorkout {
        case .running:
            //heart rate
            datapoint.id = count
            datapoint.time = time
            datapoint.datapoint = String(heartRate)
            datapoint.type = "Heart Rate"
            try! realm.write {
                savedWorkout.dataPoints.append(datapoint)
            }
            
//            writeWorkoutToDatabase()
            //avg heart rate
            datapoint = Datapoint()
            datapoint.id = count
            datapoint.time = time
            datapoint.datapoint = String(averageHeartRate)
            datapoint.type = "Average Heart Rate Heart Rate"
            try! realm.write {
                savedWorkout.dataPoints.append(datapoint)
            }
            
//            writeWorkoutToDatabase()
//            //pace
//            datapoint = Datapoint()
//            datapoint.id = count
//            datapoint.time = time
//            datapoint.datapoint = String()
//            datapoint.type = "Pace"
//
//            savedWorkout.dataPoints.append(datapoint)
            //distance
            datapoint = Datapoint()
            datapoint.id = count
            datapoint.time = time
            datapoint.datapoint = String(distance)
            datapoint.type = "Total Distance"
            try! realm.write {
                savedWorkout.dataPoints.append(datapoint)
            }
            
//            writeWorkoutToDatabase()
            //steps
//            datapoint = Datapoint()
//            datapoint.id = count
//            datapoint.time = time
//            datapoint.datapoint = String()
//            datapoint.type = "steps"
//
//            savedWorkout.dataPoints.append(datapoint)
//            print("")

        case .cycling:
            print("")
            //heart rate
            //avg heart rate
            //pace
            //distance
        case .swimming:
            print("")
            //heart rate
            //avg heart rate
            //pace
            //distance
        case .functionalStrengthTraining:
            print("")
            //heart rate
            //avg heart rate
        case .flexibility:
            print("")
            //heart rate
            //avg heart rate
        case .walking:
            print("")
            //heart rate
            //avg heart rate
            //pace
            //distance
        default:
            print("")
        
        }
//        do {
//            try realm.write({
//                realm.add(savedWorkout)
//            })
//        } catch {
//            print("error saving updated saved workout from sample data")
//        }
                    writeWorkoutToDatabase()

        count += 1
        print(savedWorkout)
    }
    
    @Published var showingSummaryView: Bool = false {
        
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    //MARK: HK Setup
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
   public func startWorkout(workoutType:HKWorkoutActivityType) {
       startSampler()
       let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        
        session?.delegate = self
        builder?.delegate = self
        
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate, completion: { success, error in
            
            
        }
        )
    }
    
    func requestAuthorization() {
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead:Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            
        }
        
    }
    
    // MARK: - Session State Control
    
    @Published var running = false
    
    
    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func endWorkout() {
        session?.end()
        stopSampler()
        showingSummaryView = true
    }

    //MARK:- Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    var count = 0
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else {
            return
        }
        print(count,Date())
        count += 1
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount):
                //TODO:add swimming metrics vars and set to update
                print("swim stroke updated")
            case HKQuantityType.quantityType(forIdentifier: .distanceSwimming):
                print("swimming distance updated")
            case HKQuantityType.quantityType(forIdentifier: .stepCount):
                print("step count updated")
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        
    }
}


// MARK: - HKWorkoutSessionDelegate

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        // Wait for the session to transition states before ending the builder.

        if toState == .ended {
            stopSampler()
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout(completion: { workout, error in
                    DispatchQueue.main.async {
                        self.workout = workout
                        
                    }
                })
        }
    }
    
}
}
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder ) {
        
    }
    
        
        func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
            for type in collectedTypes {
                guard let quatityType = type as? HKQuantityType else {return}
            
                let statistics = workoutBuilder.statistics(for: quatityType)
                updateForStatistics(statistics)
                
            }
            
        }
    }

