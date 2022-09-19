

import SwiftUI

struct CameraView: View {
  @StateObject private var model = ContentViewModel()
    @Environment(\.presentationMode) var presentationMode
  var body: some View {
    ZStack {
      FrameView(image: model.frame)
        .edgesIgnoringSafeArea(.all)
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("X")
        }


      ErrorView(error: model.error)
    }.onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartRecording")), perform: { output  in
       print("Recording started")
    })
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
