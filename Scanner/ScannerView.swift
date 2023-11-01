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
    @Environment(\.openURL) private var openURL
    //camera qr outut delegate
    @StateObject private var qrDelegate = QRScannerDelegate()
    // scanned code
    @State private var scannedCode: String = ""
    
    var body: some View{
        VStack(spacing: 8){
            Button{
                
            } label: {
                Image(systemName:"xmark")
                    .font(.title3)
                    .foregroundColor(Color("Blue"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                checkCameraPermission()
            }
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
                    CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                    //make it smaller
                        .scaleEffect(0.97)
                    
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
                if session.isRunning && cameraPermission == .approved{
                    reactivateCamera()
                    activateScannerAnimation()
                }
            }
        label:{
            Image(systemName: "qrconde.viewfinder")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
            Spacer(minLength: 45)
        }
        .padding(15)
        .alert(errorMessage, isPresented: $showError){
            //setting button
            if cameraPermission == .denied{
                Button("Settings"){
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString){
                        //open settings
                        openURL(settingsURL)
                    }
                }
                
                //Canacel Button'
                Button("Cancel", role: .cancel){
                }
            }
        }
        .onChange(of: qrDelegate.scannedCode){
            newValue in
            if let code = newValue{
                scannedCode = code
                //when qr code is available stop scan
                session.stopRunning()
                // stop Scan
                deActivateScannerAnimation()
                //clear data
                qrDelegate.scannedCode = nil
            }
        }
    }
    
    //Scanner Animation Deactivate
    func deActivateScannerAnimation(){
        withAnimation(.easeInOut(duration: 0.85)){
            isScanning = false
        }
    }
    //Scanner Animation activate
    func activateScannerAnimation(){
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses:true)){
            isScanning = true
        }
    }
    
    func reactivateCamera(){
        DispatchQueue.global(qos: .background).async
        {
            session.startRunning()
        }
    }
    
    //Camera Permission
    func checkCameraPermission(){
        Task{
            switch AVCaptureDevice.authorizationStatus(for: .video){
            case.authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty{
                    // new setup
                    setupCamera()
                }else{
                    //existing
                    session.startRunning()
                }
            case.notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video){
                    cameraPermission = .approved
                    setupCamera()
                }else{
                    cameraPermission = .denied
                    presentError(_message: "Access to the Camera is denied")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError(_message: "Access to the Camera is denied")
            default: break
                
            }
        }
    }
    
    //Set up Camera
    func setupCamera(){
        do{
            //find back camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera], mediaType: .video, position: .back).devices.first
            else{
                presentError(_message: "???? Device Error")
                return
            }
            
            //camera input
            let input = try AVCaptureDeviceInput(device: device)
            //input & output can be added to session
            guard session.canAddInput(input), session.canAddOutput(qrOutput)else{
                presentError(_message: "???? Input/Output Error")
                return
            }
            
            //Add Input & Output
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            //output config
            qrOutput.metadataObjectTypes = [.qr]
            // add delegate to rerrieve fetched qr code
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            //Note session must be started on Background thread
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            activateScannerAnimation()
            
        }catch{
            presentError(_message: error.localizedDescription)
        }
    }
    
    //Present Error
    func presentError(_message: String){
        errorMessage = _message
        showError.toggle()
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}
