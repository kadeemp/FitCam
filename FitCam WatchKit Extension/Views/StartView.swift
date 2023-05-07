//
//  ContentView.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI
import HealthKit

struct StartView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection:HKWorkoutActivityType?
  
    var workoutTypes: [HKWorkoutActivityType] = [.running, .walking, .swimming, .cycling,.flexibility, .functionalStrengthTraining]
    
    var body: some View {
        List(workoutTypes) { workoutType in

            NavigationLink(workoutType.name,
                           destination: StartWorkoutView(  workoutType: workoutType), tag: workoutType, selection: $selection
                        ).padding(
                            EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
                        )
        }
        .listStyle(.carousel)
        
       
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}
//    .simultaneousGesture(TapGesture().onEnded({
//        
//        //                workoutManager.selectedWorkout = workoutType
//        //                workoutManager.startWorkout(workoutType: workoutType ?? .crossTraining)
//                        workoutManager.sendWorkoutSelection()
//                    }))

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

extension HKWorkoutActivityType: Identifiable {
    
    public var id :UInt {
        rawValue
    }
    
    var name:String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Cycling"
        case .swimming:
            return "Swimming"
        case .functionalStrengthTraining:
            return "Weightlifting"
        case .flexibility:
            return "Flexibility"
        case .walking:
            return "Walking"
        default:
            return ""
        }
    }
    
    
    
}
