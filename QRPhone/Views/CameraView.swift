//
//  CameraView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 17/2/26.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    var shouldScan: Bool = true

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Restart scanning when scannedCode is reset to nil
        if scannedCode == nil && uiViewController.isScanning == false {
            print("🔄 Restarting camera scanning")
            uiViewController.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String?
        var hasScanned = false

        init(scannedCode: Binding<String?>) {
            _scannedCode = scannedCode
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Only process if we haven't scanned yet
            guard scannedCode == nil else { return }
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                scannedCode = stringValue
                print("📷 Camera detected QR code")
            }
        }
    }
}
