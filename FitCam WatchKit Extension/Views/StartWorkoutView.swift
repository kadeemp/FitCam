//
//  StartWorkoutView.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 9/8/22.
//

import SwiftUI
import HealthKit

struct StartWorkoutView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutType: HKWorkoutActivityType?
    var body: some View {
        
        VStack{
            Text("\(workoutType?.name ?? "name needed" )").fontWeight(.semibold).padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)).font(.title3)
            
            NavigationLink(destination: SessionPagingView()) {
                    Text("Start Workout")
              
            }.simultaneousGesture(TapGesture().onEnded({
//                workoutManager.selectedWorkout = workoutType
//                workoutManager.startWorkout(workoutType: workoutType ?? .crossTraining)
                workoutManager.sendWorkoutStartRequest()
            }))
        }.onAppear {
            workoutManager.sendWorkoutSelection()
        }
    }
}

struct RoundButtonStyle:ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.frame(width: 140, height: 140, alignment: .center).background(Color.red).clipShape(Circle())
    }
}

//frame(width: 200, height: 200, alignment: .center).clipShape(Circle())
struct StartWorkoutView_Previews: PreviewProvider {
    static var title:String = "Workout Type"
    static var workoutType:HKWorkoutActivityType = .crossTraining
    static var previews: some View {
        StartWorkoutView(workoutType: workoutType)
    }
}
