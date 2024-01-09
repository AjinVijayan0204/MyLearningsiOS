//
//  ContentView.swift
//  TwitterAnimation
//
//  Created by Ajin on 09/01/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AnimationImageView()
                .frame(width: 80, height: 80)

            Text("Like")
        }
        .padding()
    }
    
}

struct AnimationImageView: UIViewRepresentable{
    
    let imgView = UIImageView()
    
    func makeUIView(context: Context) -> some UIView {
        
        imgView.image = UIImage(named: "tile00")
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapLabel)))
        
        return imgView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
        
    class Coordinator: NSObject {
            var parent: AnimationImageView
            var likeImages = [UIImage]()
            init(parent: AnimationImageView) {
                self.parent = parent
                for i in 0...28{
                    likeImages.append(UIImage(named: "tile0\(i)")!)
                }
            }

            @objc func didTapLabel() {
                parent.imgView.animationImages = likeImages
                parent.imgView.animationDuration = 0.6
                parent.imgView.animationRepeatCount = 1
                parent.imgView.image = likeImages.last
                parent.imgView.startAnimating()

            }
        }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
