//
//  CameraView_i.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/19/22.
//

import Foundation
import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
struct CameraViewVC: UIViewControllerRepresentable {

  typealias UIViewControllerType = CameraViewController
 
  func makeUIViewController(context: Context) -> CameraViewController {
      CameraViewController.shared
  }

  func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
  }

  public func switchCamera() {
      CameraViewController.shared.switchCamera()
  }

  public func startRecording() {
      CameraViewController.shared.captureMovie()
  }

  public func stopRecording() {
      CameraViewController.shared.stopRecording()
  }
    public func activeInput() -> AVCaptureDeviceInput? {
        var b = CameraViewController.shared.activeInput
        return b
    }



}
