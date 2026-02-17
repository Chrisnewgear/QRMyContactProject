//
//  QRDisplayView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI

struct QRDisplayView: View {
    @ObservedObject var viewModel: UserDataViewModel
    
    
    var body: some View {
        VStack(spacing: 20){
            Text("¡Hola, \(viewModel.userData.firstName) \(viewModel.userData.lastName)!")
                .font(.title)
                .bold()
            
            Text("Tu teléfono: \(viewModel.userData.phoneNumber)").font(.headline)
            
            if let qrCodeData = viewModel.generateQRCode(),
               let uiImage = UIImage(data: qrCodeData){
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            Button(action: {
                viewModel.showingScanner = true
            }){
                Label("Escanear QR", systemImage: "qrcode.viewfinder").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .sheet(isPresented: $viewModel.showingScanner){
                QRScannerView()
            }
            
            Button("Editar información") {
                viewModel.isDataSaved = false
            }
            .padding(.top)
            
            Button("Eliminar datos", role: .destructive){
                viewModel.showAlert = true
            }
            .padding(.top)
            .alert("¿Estás seguro de que quieres eliminar tus datos?", isPresented: $viewModel.showAlert){
                Button("Cancelar", role: .cancel){}
                Button("Eliminar", role: .destructive){
                    viewModel.deleteData()
                }
            }message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
        .padding()
    }
}
