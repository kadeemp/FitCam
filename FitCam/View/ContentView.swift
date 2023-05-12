import SwiftUI
import AVKit
import RealmSwift

@available(iOS 16.0, *)


struct ContentView: View {
    @EnvironmentObject var realmWrapper: RealmWrapper
    @Environment(\.presentationMode) var presentationMode
    @Binding var isWorkoutSelected: Bool
    @State var cameraVC: CameraViewVC?
    @State var videos: [URL] = []

    init(isWorkoutSelected: Binding<Bool>) {
        _isWorkoutSelected = isWorkoutSelected
        _cameraVC = State(initialValue: CameraViewVC())
    }

    var body: some View {
          NavigationView {
              List {
                  ForEach(Array(realmWrapper.workouts!), id: \.self) { workout in
                      NavigationLink(destination: VideoPlayerView(workout: workout)) {
                          Text(workout.workoutType)
                      }
                      .swipeActions(edge: .trailing) {
                          Button(action: {
                              deleteWorkout(workout)
                          }) {
                              Label("Delete", systemImage: "trash")
                          }
                          .tint(.red)
                      }
                  }
              }
              .onAppear {
                  cameraVC = CameraViewVC()
              }
          }
          .navigationTitle("Saved Workouts")
          .fullScreenCover(isPresented: $isWorkoutSelected) {
              ZStack {
                  cameraVC
                  cameraVC.onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartRecording"))) { output in
                      print("Recording started")
                      cameraVC!.startRecording()
                  }
                  .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StopRecording"))) { output in
                      print("Recording stopped")
                      cameraVC!.stopRecording()
                      isWorkoutSelected = false
                      // TODO: Send notification
                  }
              }
          }
      }
    
    
    private func deleteWorkout(_ workout: SavedWorkout) {
        realmWrapper.deleteWorkout(workout)
        // Handle any additional logic after deleting the workout
    }
}


struct VideoPlayerView: View {
    @ObservedObject var playerViewModel: PlayerViewModel
    var workout: SavedWorkout
    let player: AVPlayer
    
    init(workout: SavedWorkout) {
        self.workout = workout
        
        let videoURL = URL(fileURLWithPath: workout.videoURL)
        let videoPath = videoURL.path
        let endIndex = videoPath.range(of: "/", options: .backwards)?.lowerBound ?? videoPath.endIndex
        let pathSuffix = String(videoPath.suffix(from: endIndex))
        let correctedPath = "file://" + FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WorkoutVideos").appendingPathComponent(pathSuffix).path
        
        if let mainURL = URL(string: correctedPath) {
            self.player = AVPlayer(url: mainURL)

            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: mainURL.path) {
                
            } else {
                print("File does not exist at path: \(mainURL.path)")
            }
        } else {
            print("Error creating URL with path: \(correctedPath)")
            self.player = AVPlayer()
        }
        if let playerItem = self.player.currentItem, let asset = playerItem.asset as? AVURLAsset {
        } else {
            print("Video URL is unknown.")
        }
        
        // Initialize playerViewModel with start time from workout data
        let startTimeString = workout.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        let startTime = dateFormatter.date(from: startTimeString) ?? Date()
        self.playerViewModel = PlayerViewModel(workout: workout)
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .onAppear {
                    // Play the video when the view appears
                    UIApplication.shared.isIdleTimerDisabled = true
                    player.play()
                    print("Player status: \(player.status.rawValue)")
                }
                .onDisappear {
                    // Stop the video when the view disappears
                    UIApplication.shared.isIdleTimerDisabled = false
                    player.pause()
                    playerViewModel.timer?.invalidate()
                }
            HStack {
                VStack {
                    Text("Elapsed Time: ")
//                    Text("\(playerViewModel.elapsedTimeString)")
//                    Text("\(playerViewModel.elapsedTimeSinceWorkoutStartString)")
                    Text("Heart Rate: \(playerViewModel.heartRateString)")
                }


                    .onReceive(playerViewModel.elapsedTimeSinceWorkoutStartPublisher) { _ in
                        // Update elapsed time label every second
                        playerViewModel.updateElapsedTime()
                        playerViewModel.updateHeartRate()

                    }
            }.onAppear {
                playerViewModel.startTimer()
            }
        }
    }
}



class PlayerViewModel: ObservableObject {
    private let workout: SavedWorkout
    private let calendar = Calendar.current
    var timer: Timer?
    
    @Published var elapsedTimeSinceWorkoutStart: TimeInterval = 0.0
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var heartRate: Int?
    
    var heartRateDataPoints: [Datapoint] = []
    var heartRateCount = 0

    var elapsedTimeSinceWorkoutStartPublisher: Published<TimeInterval>.Publisher { $elapsedTimeSinceWorkoutStart }

    
    init(workout: SavedWorkout) {
        self.workout = workout
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        guard let workoutStartTime = dateFormatter.date(from: workout.date) else {
            self.elapsedTimeSinceWorkoutStart = 0.0
            return
        }
        self.elapsedTimeSinceWorkoutStart = -workoutStartTime.timeIntervalSinceNow
    }
    
     func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
            self?.updateHeartRate()
        }
        timer?.tolerance = 0.1
    }
    
     func updateElapsedTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        guard let workoutStartTime = dateFormatter.date(from: workout.date) else {
            return
        }
        elapsedTime = workoutStartTime.timeIntervalSinceNow
    }
    
    func updateHeartRate() {

        if heartRateDataPoints.isEmpty {
            for dataPoint in workout.dataPoints {
                if dataPoint.type == "Heart Rate" {
                    heartRateDataPoints.append(dataPoint)
                }
            }

        }
        let datapoint = heartRateDataPoints[heartRateCount]
        heartRate = Int(Double(datapoint.datapoint)!) 
        print(heartRate, datapoint.datapoint)
        if heartRateCount == heartRateDataPoints.count {
            timer?.invalidate()
            return
        }
        heartRateCount += 1
        

//        guard let heartRateDataPoint = workout.dataPoints
//                .filter({ $0.type == "Heart Rate" })
//                .min(by: { datapointTimeInterval($0.time) ?? .greatestFiniteMagnitude < datapointTimeInterval($1.time) ?? .greatestFiniteMagnitude })
//
//
//        else {
//            print("failed to find datapoint")
//            heartRate = nil
//            return
//        }
//
//        // Parse the heart rate value from the datapoint string
//        if let heartRate = Double(heartRateDataPoint.datapoint) {
//            self.heartRate = Int(heartRate)
//        } else {
//            // Failed to parse heart rate, set to nil or handle accordingly
//            self.heartRate = nil
//        }
    }

    private func datapointTimeInterval(_ datapointTime: String) -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        guard let referenceDate = dateFormatter.date(from: datapointTime) else {
            return 0.0
        }
        
        return referenceDate.timeIntervalSinceNow
    }
    
    var elapsedTimeSinceWorkoutStartString: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.formattingContext = .standalone
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = 3
        return formatter.string(from: elapsedTimeSinceWorkoutStart) ?? "00:00:00"
    }
    var heartRateString: String {
        if let heartRate = heartRate {
            return String(heartRate)
        } else {
            return "100" // Or any default value when heart rate is nil
        }
    }
    var elapsedTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.formattingContext = .standalone
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = 3
        return formatter.string(from: elapsedTime) ?? "00:00:00"
    }
}



@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isWorkoutSelected: .constant(false))
    }
}
