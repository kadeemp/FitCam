//
//  CameraViewModel.swift
//  FitCam
//
//  Created by Kadeem Palacios on 5/6/23.
//

import Foundation

class CameraViewModel: ObservableObject {
    @Published var videos: [URL] = []
    
    func addURL(_ url:URL) {
        videos.append(url)
    }
}
