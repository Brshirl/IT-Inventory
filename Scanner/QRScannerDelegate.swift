//
//  QRScannerDelegate.swift
//  Inventory
//
//  Created by Brett Shirley on 10/23/23.
//

import Foundation
import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate{
    @Published var scannedCode: String?
    func metadata(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection:AVCaptureConnection){
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else {return}
            guard let scannedCode = readableObject.stringValue else {return}
            print(scannedCode)
        }
    }
}
