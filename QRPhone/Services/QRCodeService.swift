//
//  QRCodeService.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//
import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

class QRCodeService{
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    func generateQRCode(from string: String) -> Data? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage{
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgImage).pngData()
            }
        }
        return nil
    }
}
