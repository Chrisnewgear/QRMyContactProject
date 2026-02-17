//
//  QRScannerView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scannedCode: String?
    @State private var showAlert = false
    @State private var alertMessage  = ""
    
    
    var body: some View {
        NavigationView{
            ZStack{
                QRCodeScanner(scannedCode: $scannedCode)
                    .edgesIgnoringSafeArea(.all)
                
                
                VStack{
                    Spacer()
                    
                    if let code = scannedCode{
                        Text("Código escaneado: ")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        
                        
                        Text(code)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("Escanear QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cerrar"){
                        dismiss()
                    }
                }            
            }
            .alert("Código QR escaneado", isPresented: $showAlert){
                Button("OK"){
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: scannedCode) { _, newValue in
                if let code = newValue {
                    alertMessage = "Teléfono detectado: \(code)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    QRScannerView()
}
