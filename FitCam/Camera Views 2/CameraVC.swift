//
//  CameraVC.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/19/22.
//

import UIKit
import AVFoundation
import SwiftUI
import PhotosUI

import WatchConnectivity
@available(iOS 16.0, *)
class CameraViewController: UIViewController {

  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  let movieOutput = AVCaptureMovieFileOutput()

    

  var tempURL: URL? {
    let directory = NSTemporaryDirectory() as NSString
    if directory != "" {
      let path = directory.appendingPathComponent("video.mov")
      return URL(fileURLWithPath: path)
    }
    return nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSession()
    setupPreview()
    startSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    stopSession()
  }

  func setupSession() {
    captureSession.beginConfiguration()
    guard let camera = AVCaptureDevice.default(for: .video) else {
      return
    }
    guard let mic = AVCaptureDevice.default(for: .audio) else {
      return
    }
    do {
      let videoInput = try AVCaptureDeviceInput(device: camera)
      let audioInput = try AVCaptureDeviceInput(device: mic)
      for input in [videoInput, audioInput] {
        if captureSession.canAddInput(input) {
          captureSession.addInput(input)
        }
      }
      activeInput = videoInput
    } catch {
      print("Error setting device input: \(error)")
      return
    }
    captureSession.addOutput(movieOutput)
    captureSession.commitConfiguration()
  }

  func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    let devices = discovery.devices.filter {
      $0.position == position
    }
    return devices.first
  }

  public func switchCamera() {
    let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
    guard let device = camera(for: position) else {
        return
    }
    captureSession.beginConfiguration()
    captureSession.removeInput(activeInput)
    do {
      activeInput = try AVCaptureDeviceInput(device: device)
    } catch {
      print("error: \(error.localizedDescription)")
      return
    }
    captureSession.addInput(activeInput)
    captureSession.commitConfiguration()
  }

  func setupPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.bounds
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    view.layer.addSublayer(previewLayer)
  }

  func startSession() {
    if !captureSession.isRunning {
      DispatchQueue.global(qos: .default).async { [weak self] in
        self?.captureSession.startRunning()
      }
    }
  }

  func stopSession() {
    if captureSession.isRunning {
      DispatchQueue.global(qos: .default).async() { [weak self] in
        self?.captureSession.stopRunning()
      }
    }
  }

  public func captureMovie() {
    guard let connection = movieOutput.connection(with: .video) else {
      return
    }
    if connection.isVideoStabilizationSupported {
      connection.preferredVideoStabilizationMode = .auto
    }
    let device = activeInput.device
    if device.isSmoothAutoFocusEnabled {
      do {
        try device.lockForConfiguration()
        device.isSmoothAutoFocusEnabled = true
        device.unlockForConfiguration()
      } catch {
        print("error: \(error)")
      }
    }
      do {
          let videoPath = "WorkoutVideos"
          let uuid = UUID().uuidString
          var videoDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
          videoDirectory = videoDirectory.appending(path: videoPath)
   
          try FileManager.default.createDirectory(atPath: videoDirectory.path, withIntermediateDirectories: true, attributes: nil)
          videoDirectory = videoDirectory.appending(path: "\(uuid).mov")
          print("videoDirectory: = \(videoDirectory)")
          movieOutput.startRecording(to: videoDirectory, recordingDelegate: self)
      }
      catch {
          print("error recording to video directory: \(error)")
      }

  }

  public func stopRecording() {
    if movieOutput.isRecording {
      movieOutput.stopRecording()
    }
  }

}

@available(iOS 16.0, *)
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error = error {
      print("error recording Output: \(error)")
    } else {

                      
        if WCSession.isSupported() {
            print("WC is supported ")
            let session = WCSession.default
            if session.isWatchAppInstalled {
                print("Watch app is installed ", #function)
                do {
                    try session.updateApplicationContext(["OutputURLUpdate":outputFileURL.absoluteString])
                } catch {
                    print("error sending watch message: \(error)")
                }
            } else {
                print("Watch app not installed", #function)
            }
        }
 //saves to photo gallery
//      PHPhotoLibrary.requestAuthorization { status in
//        if status == .authorized {
//          PHPhotoLibrary.shared().performChanges {
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//          } completionHandler: { (success, error) in
//              print("Video saved to photos library")
//
//          }
//        }
//      }
    }
  }
}
