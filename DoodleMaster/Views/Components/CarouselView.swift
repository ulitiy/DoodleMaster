//
//  CarouselView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 09.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Combine

//https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators
struct CarouselView<Content>: View where Content: View {
    let maxIndex: Int
    var content: () -> Content

    @State private var offset = CGFloat.zero
    @State private var dragging = false
    @State var index = 0
    @State var cancelDrag: AnyCancellable?

    init(@ViewBuilder content: @escaping () -> Content) {
        if let v = Mirror(reflecting: content()).descendant("value") {
            let tm = Mirror(reflecting: v)
            self.maxIndex = tm.children.count - 1
        } else {
            self.maxIndex = 0
        }
        self.content = content
    }
    
    func onEnded(_ value: _ChangedGesture<DragGesture>.Value, geometry: GeometryProxy) {
        cancelDrag?.cancel()
        let predictedEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
        let predictedIndex = Int(round(predictedEndOffset / -(geometry.size.width+0.0001)))
        self.index = self.clampedIndex(from: predictedIndex)
        print(index)
        withAnimation(.easeOut) { // animation only on false!
            self.dragging = false
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                Group {
                    HStack(spacing: 0) {
                        content()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .offset(x: self.offset(in: geometry), y: 0)
                    }.allowsHitTesting(false)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                .clipped()
                .overlay(
                    Rectangle()
                        .opacity(0.00001)
                        .gesture(
                            DragGesture(minimumDistance: 20).onChanged { value in
                                self.dragging = true
                                self.offset = -CGFloat(self.index) * geometry.size.width + max(min(value.translation.width, geometry.size.width), -geometry.size.width)
                                let just = Just<Bool>(true).delay(for: .seconds(1), scheduler: RunLoop.main)
                                cancelDrag?.cancel()
                                cancelDrag = just.sink { _ in
                                    onEnded(value, geometry: geometry)
                                }
                            }
                            .onEnded { value in
                                onEnded(value, geometry: geometry)
                            }
                            , including: .gesture)
                )
            }
            if maxIndex > 0 {
                PageIndicator(index: $index, maxIndex: maxIndex)
            }
        }
        .cornerRadius(40)
        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color(hex: "303b96ff")!, lineWidth: 4))
    }

    func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }

    func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, self.index - 1), self.index + 1)
        return max(min(newIndex, maxIndex), 0)
    }
}

struct PageIndicator: View {
    @Binding var index: Int
    let maxIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...maxIndex, id: \.self) { index in
                if index == self.index {
                    Circle()
                        .fill(index == self.index ? Color(hex: "303b96ff")! : Color(hex: "bbbbbbff")!)
                        .frame(width: 9.2, height: 9.2)
                } else {
                    Circle()
                        .stroke(Color(hex: "303b96ff")!, lineWidth: 1.2)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(15)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 100) {
            CarouselView {
                MyImageView(name: "thumbnails/DEBUG")
                MyImageView(name: "1-2")
                MyImageView(name: "1-3")
            }.frame(width: 200, height: 200).padding(.top, 100)
            CarouselView {
                MyImageView(name: "1-1")
                MyImageView(name: "1-2")
                MyImageView(name: "1-3")
                MyImageView(name: "1-4")
            }.frame(width: 200, height: 200)
        }
        .previewDevice("iPad (8th generation)")
        .previewLayout(.fixed(width: 1366, height: 1024))

    }
}
