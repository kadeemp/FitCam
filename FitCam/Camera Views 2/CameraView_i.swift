//
//  CameraView_i.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/19/22.
//

import Foundation
import SwiftUI

struct CameraViewVC: UIViewControllerRepresentable {

  typealias UIViewControllerType = CameraViewController
  private let cameraViewController: CameraViewController

  init() {
    cameraViewController = CameraViewController()
  }

  func makeUIViewController(context: Context) -> CameraViewController {
    cameraViewController
  }

  func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

  }

  public func switchCamera() {
    cameraViewController.switchCamera()
  }

  public func startRecording() {
    cameraViewController.captureMovie()
  }

  public func stopRecording() {
    cameraViewController.stopRecording()
  }



}
