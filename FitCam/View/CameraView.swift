

import SwiftUI

struct CameraView: View {
  @StateObject private var model = ContentViewModel()

  var body: some View {
    ZStack {
      FrameView(image: model.frame)
        .edgesIgnoringSafeArea(.all)
      
      ErrorView(error: model.error)
    }
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
