//
//  MyImageView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

// Made for resizing vector based PDF graphics bacause Image() doesn't support it
struct MyImageView: UIViewRepresentable {
  var name: String
  var contentMode: UIView.ContentMode = .scaleAspectFit

  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView()
    imageView.setContentCompressionResistancePriority(.fittingSizeLevel,
                                                      for: .vertical)
    return imageView
  }

  func updateUIView(_ uiView: UIImageView, context: Context) {
    uiView.contentMode = contentMode
    if let image = UIImage(named: name) {
      uiView.image = image
    }
  }
}

struct MyImageView_Previews: PreviewProvider {
    static var previews: some View {
        MyImageView(name: "medal")
    }
}
