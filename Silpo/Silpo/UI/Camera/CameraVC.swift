//
//  New_CameraVC.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private let cameraView: UIView = {
        let view = UIView()
        return view
    }()
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    private var lastProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            guard let self = self else { return }
            if response {
                DispatchQueue.main.async {
                    self.sessionSetup()
                }
            } else {
                self.scanningNotPossible()
            }
        }
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if session?.isRunning == false {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if session?.isRunning == true {
            session.stopRunning()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductVC",
            let destination = segue.destination as? ProductVC {
            destination.product = self.lastProduct!
        }
    }
    
    func showProductVC(with product: Product) {
        lastProduct = product
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "showProductVC", sender: self)
        }
    }
    
    func barcodeDetected(code: String) {

        Networking.shared.fetchProduct(by: code) { (response, error) in
            
            if let product = response {
                DispatchQueue.main.async {
                    self.showProductVC(with: product)
                }
            } else if error != nil {
                print("Error loading data: \(error!)")
            } else {
                print("Error unknown")
            }
        }
        
    }
}

// MARK: - AVSession setup
extension CameraVC {
    
    func sessionSetup() {
        
        // Create a session object.
        session = AVCaptureSession()
        
        // Set the captureDevice.
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        // Create input object.
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed try AVCaptureDeviceInput")
            return
        }
        
        // Add input to the session.
        if (session.canAddInput(videoInput!)) {
            session.addInput(videoInput!)
        } else {
            scanningNotPossible()
        }
        
        // Create output object.
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Add output to the session.
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            // Send captured data to the delegate object via a serial queue.
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            
            // Set barcode type for which to scan: EAN-13.
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
            
        } else {
            scanningNotPossible()
        }
        
        // Add previewLayer and have it show the video data.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        
        // Begin the capture session.
        session.startRunning()
    }
    
    func scanningNotPossible() {
        
        // Let the user know that scanning isn't possible with the current device.
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Get the first object from the metadataObjects array.
        if let barcodeData = metadataObjects.first {

            // Turn it into machine readable code
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;

            if let readableCode = barcodeReadable?.stringValue {

                // Send the barcode as a string to barcodeDetected()
                barcodeDetected(code: readableCode)
            }

            // Vibrate the device to give the user some feedback.
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // Avoid a very buzzy device.
            session.stopRunning()
        }
    }
}

// MARK: - UI
extension CameraVC {
    
    func configureUI() {
        
        // Setup cameraView
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
