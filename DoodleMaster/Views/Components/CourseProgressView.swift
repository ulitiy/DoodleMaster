//
//  CourseProgressView.swift
//  ArtWorkout
//
//  Created by Aleksandr Ulitin on 08.02.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseProgressView: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { p in
                    p.addArc(
                        center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                        radius: geometry.size.width / 2 - 5,
                        startAngle: .radians(1.5 * .pi),
                        endAngle: .radians(1.5 * .pi + 2 * .pi * value),
                        clockwise: true)
                }
                .strokedPath(.init(lineWidth: 12))
                .foregroundColor(Color(hex: "303b96ff"))
                Path { p in
                    p.addArc(
                        center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                        radius: geometry.size.width / 2 - 5,
                        startAngle: .radians(1.5 * .pi),
                        endAngle: .radians(1.5 * .pi + 2 * .pi * value),
                        clockwise: false)
                }
                .strokedPath(.init(lineWidth: 12))
                .foregroundColor(Color(hex: "00ea7aff"))
            }
        }
    }
}

struct CourseProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CourseProgressView(value: 0.3)
    }
}
