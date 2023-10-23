//
//  Scanner.swift
//  Inventory
//
//  Created by Brett Shirley on 10/23/23.
//

import SwiftUI
import AVKit

struct ScannerView: View{
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    //QR Scanner AV OUTPUT
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    //Error Prop
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View{
        VStack(spacing: 8){
            Button{
                
            } label: {
                Image(systemName:"xmark")
                    .font(.title3)
                    .foregroundColor(Color("Blue"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Place the QR code inside this area.")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
                Spacer(minLength: 0)
            
            //Scanner
            GeometryReader{
                let size = $0.size
                
                ZStack{
                    CameraView(frameSize: size, session: $session)
                    
                    ForEach(0...4, id: \.self){ index in let rotation = Double(index)*90
                        RoundedRectangle(cornerRadius: 2,style: .circular)
                        //trimm to get scanner edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color("Blue"), style: StrokeStyle(lineWidth: 5, lineCap: .round,lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                        
                    }
                }
                //Square
                .frame(width: size.width, height: size.width)
                //animate
                .overlay(alignment: .top, content: {
                    Rectangle()
                        .fill(Color("Blue"))
                        .frame(height:2.5)
                        .shadow(color: .black.opacity(0.8), radius: 8, x:0, y:15)
                        .offset(y: isScanning ? size.width:0)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal,45)
            Spacer(minLength: 15)
            
            Button{
                
            }
        Label:{
            Image(systemName: "qrconde.viewfinder")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
            Spacer(minLength: 45)
        }
        .padding(15)
        .alert(errorMessage, isPresented: $showError){
            
        }
    }
    
    //Scanner Animation
    func activateScannerAnimation(){
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses:true)){
            isScanning = true
        }
    }
    
    //Camera Permission
    func checkCameraPermission(){
        Task{
            switch AVCaptureDevice.authorizationStatus(for: .video){
            case.authorized:
                cameraPermission = .approved
            case.notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video){
                    cameraPermission = .approved
                }else{
                    cameraPermission = .denied
                }
            case .denied, .restricted:
                cameraPermission = .denied
            default: break
                
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}
