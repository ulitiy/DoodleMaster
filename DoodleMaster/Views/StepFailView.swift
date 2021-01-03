//
//  StepFailView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct StepFailView: View {
    var body: some View {
        ZStack {
            Rectangle().fill(Color.white)
            Image(systemName: "xmark").foregroundColor(.red).font(.system(size: 130.0, weight: .bold))
        }
        .zIndex(1)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
    }
}

struct StepFailView_Previews: PreviewProvider {
    static var previews: some View {
        StepFailView().previewLayout(.fixed(width: 1366, height: 1024))
    }
}
