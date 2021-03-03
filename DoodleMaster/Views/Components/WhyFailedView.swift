//
//  WhyFailedView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct WhyFailedView: View {
    var whyFailed: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                .font(.system(size: 40))
            Text(whyFailed)
                .font(.custom("LucidaGrande", size: 25))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading).padding()
    }
}

struct WhyFailedView_Previews: PreviewProvider {
    static var previews: some View {
        WhyFailedView(whyFailed: "Try to be more precise and match the expected image.")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
