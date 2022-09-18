//
//  CameraManager.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/10/22.
//

import Foundation


class CameraManager: NSObject, ObservableObject  {
    
    @Published var isWorkoutSelected:Bool = false {
        didSet {
            if isWorkoutSelected == true {
                print("Success")
            }
        }
    }
}
