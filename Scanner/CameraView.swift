//
//  CameraView.swift
//  Inventory
//
//  Created by Brett Shirley on 10/23/23.
//

import Foundation
import SwiftUI
import AVKit

//Camera View
struct CameraView: UIViewRepresentable {
    var frameSize: CGSize
    //Camera session
    @Binding var session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        //Camera Frame Size
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.frame = .init(origin: .zero, size: frameSize)
        cameraLayer.videoGravity = .resizeAspectFill
        cameraLayer.masksToBounds = true
        view.layer.addSublayer(cameraLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        <#code#>
    }
}
