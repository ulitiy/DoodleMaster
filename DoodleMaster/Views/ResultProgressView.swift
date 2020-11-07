//
//  ResultProgressView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 06.11.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct ResultProgressView: View {
    var positive: Double
    var negative: Double
    
    func overall() -> Double {
        let o = positive + negative
        return o > 0 ? o : 0
    }
    
    var body: some View {
        GeometryReader { metrics in
            HStack(spacing: 0) {
                Rectangle().fill(Color.green).frame(width: metrics.size.width * CGFloat(overall()))
                Rectangle().fill(Color.red).frame(width: metrics.size.width * CGFloat(-negative))
                Rectangle().fill(Color.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 10, idealHeight: 10, maxHeight: 10, alignment: .center)
    }
}

struct ResultProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ResultProgressView(positive: 0.6, negative: -0.2)
    }
}
