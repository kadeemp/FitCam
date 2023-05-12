//
//  WorkoutManager.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/28/22.
//

import Foundation
import HealthKit
import SwiftUI
//import RealmSwift
import WatchConnectivity


class WorkoutManager: NSObject, ObservableObject {
    
    var timer = Timer()
//    var realm:Realm!

    var savedWorkout:SavedWorkout2!
 
    func setupRealm() {
//
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)
        //TODO:- Delete all data at this old path
//        let appGroupsURL:URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:"group.com.rileytestut.AltStore.68A9E944ZN")
//        print("appgroup url: \(appGroupsURL  ) \n", #function)
        
//        if #available(watchOSApplicationExtension 9.0, *) {
//            let datapath = docURL?.appending(path: "FitCam-db.realm")
//
//            var config =  Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
//            do {
//                try realm = Realm(configuration: config)
//                print("realm fileurl \(realm.configuration.fileURL)")
////                let workouts = realm.objects(SavedWorkout.self)
////                print("list of workouts: \n \(workouts)")
//            } catch {
//                print("failed to setup configuration. Error: \(error)")
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        

    }
    var selectedWorkout: HKWorkoutActivityType?
    
    //MARK:= Watchkit Message Center
    func sendWorkoutData() {
        if WCSession.isSupported() {
            let session = WCSession.default

            do {

                let wkdata2 = try JSONEncoder().encode(savedWorkout)
                
                session.sendMessageData(wkdata2) { data in
                    print("replyhandler from sendMessageData 2 \n data:\(data)")
                }

            } catch {
                print("error converting workout data: \(error)")
            }
        }
    }
    func sendWorkoutSelection() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.sendMessage((["request":"workoutSelected"])) { response in
                print("received Reply \(response)")
            }
        }
            }
    func sendWorkoutStartRequest() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.sendMessage((["request":"workoutStarted"])) { response in
                print("received Reply \(response)")
            }
        }

    }
    func sendWorkoutStopRequest() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.sendMessage((["request":"workoutStopped"])) { response in
                print("received Reply \(response)")
            }
        }
    }
    //MARK: - Sampler Setup
    
    func startSampler() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.sampleWorkoutData()
        })
//        guard let realm = realm else {
//            print("REALM NOT CREATED FOR SAMPLER")
//            return}

        savedWorkout = SavedWorkout2(workoutType: "", date: "", dataPoints: [], videoURL: "")
        savedWorkout.date = Date().formatted(date: .abbreviated, time: .standard)
        savedWorkout.workoutType = selectedWorkout?.name ?? ""
        
        do {
//            try realm.write({
//                realm.add(savedWorkout)
            }
        
        catch {
         print("error saving workout from sampler start")
        }
        
    }
    func stopSampler() {
        timer.invalidate()
    }
    
    func writeWorkoutToDatabase() {
//        guard let realm = realm else {
//            print("REALM NOT CREATED, ",#function)
//            return}

        do {
//            try realm.write {
////                realm.add(savedWorkout)
//            }
        }
        catch {
            print("")
        }
    }
    
    var samplerCount = 0
    
    func sampleWorkoutData() {
//        guard let realm = realm else {
//            print("REALM NOT CREATED ",#function)
//            return}
        var date = Date().formatted(date: .abbreviated, time: .omitted)
        var time = Date().formatted(date: .omitted, time: .standard)
        var datapoint = Datapoint2(type: "", time: "", id: .zero, datapoint: "")
        
        switch selectedWorkout {
        case .running:
            //heart rate
            datapoint = Datapoint2(type: "Heart Rate", time: time, id: count, datapoint: String(heartRate))

//            print("DataPoint Added: \(datapoint.self) \n")
//                savedWorkout.dataPoints.append(datapoint)
            
            
//            writeWorkoutToDatabase()
            //avg heart rate
            datapoint = Datapoint2(type: "Average Heart Rate Heart Rate", time: time, id: count, datapoint: String(averageHeartRate))

//            print("DataPoint Added: \(datapoint.self) \n")
//                savedWorkout.dataPoints.append(datapoint)
                        
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
            datapoint = Datapoint2(type: "Total Distance", time: time, id: count, datapoint: String(distance))
    
//            print("DataPoint Added: \(datapoint.self) \n")
//                savedWorkout.dataPoints.append(datapoint)
            
            
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
//        print(savedWorkout)
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
            running = true

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
            switch success {
            case false:
                fatalError("error beginning collection of builder: \(error)")
            case true:
                print("success creating builder")
            
            }
        }
        )
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
        running = false
        stopSampler()
        sendWorkoutStopRequest()
        showingSummaryView = true
        
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

