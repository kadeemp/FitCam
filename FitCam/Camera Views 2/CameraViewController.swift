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
    var activeInput: AVCaptureDeviceInput? {
        didSet {
            print("activeInput changed to: \(activeInput)")
        }
    }
    let movieOutput = AVCaptureMovieFileOutput()
    
    static let shared = CameraViewController()

    
    
//    @Binding var videos: [URL]
    
//    init(videos: Binding<[URL]>) {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let workoutVideosDirectory = documentsDirectory.appendingPathComponent("WorkoutVideos")
//        let videosURLs = try? FileManager.default.contentsOfDirectory(at: workoutVideosDirectory, includingPropertiesForKeys: nil, options: [])
//        let videos2 = videosURLs ?? []
//        print("the value of videoURLs is \(videosURLs)")
////        _videos = Binding.constant(videos2)
////        super.init(nibName: nil, bundle: nil)
//    }
    

    
    var tempURL: URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("video.mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSession()
        setupPreview()
        startSession()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                } else {
                    print("")
                }
            }
            self.activeInput = videoInput
            print("active input has been set\(self.activeInput)")
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
            } else {
                print("FAILED TO ADD OUTPUT")
            }
            
        } catch {
            print("Error setting device input: \(error)")
            return
        }

        

        captureSession.commitConfiguration()
    }
    
    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discovery.devices.filter {
            $0.position == position
        }
        return devices.first
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
       if let connection = movieOutput.connection(with: .video)  {
           if connection.isVideoStabilizationSupported {
               connection.preferredVideoStabilizationMode = .auto
           }
        }
//        
        guard let deviceInput = activeInput else {
            print("activeInput is nil")
            return
        }
        
        let device = deviceInput.device
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
        print("")
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }
    

    public func switchCamera() {
        //TODO:- fix this so that it saffely unwraps
        let position: AVCaptureDevice.Position = (activeInput!.device.position == .back) ? .front : .back
        guard let device = camera(for: position) else {
            return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(activeInput!)
        do {
            activeInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("error: \(error.localizedDescription)")
            return
        }
        captureSession.addInput(activeInput!)
        captureSession.commitConfiguration()
    }
}

@available(iOS 16.0, *)
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("error recording Output: \(error)")
        } else {
            
//            videos.append(outputFileURL)
//            $videos.wrappedValue = videos
            
            
            
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
