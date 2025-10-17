//
//  NextPrevious.swift
//  SlideShowDemo
//
//  Created by jht2 on 3/10/22.
//

import SwiftUI


struct SlideShowView: View {
    @State var slideIndex = 0
    var body: some View {
        VStack {
            Text("Slide Show")
                .font(Font.system(size: 30, weight: .bold))
                .padding()
            let name = slides[slideIndex]
            SingleSlideView(name: name)
            HStack {
                Button(action: previousItemAction) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
                Spacer()
                Button(action: nextItemAction) {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
            }
        }
    }
    
    func previousItemAction() {
        if (slideIndex > 0) {
            slideIndex -= 1;
        }
    }
    func nextItemAction() {
        if (slideIndex < slides.count-1) {
            slideIndex += 1;
        }
    }
}

// The view use to represent a slide
struct SingleSlideView: View {
    var name:String
    var body: some View {
        VStack {
            Image(systemName: name)
                .resizable()
            Text(name)
        }
    }
}

#Preview {
  SlideShowView()
}
