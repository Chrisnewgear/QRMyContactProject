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
        ZStack {
            // Background is provided by parent view
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tu Tarjeta QR")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Comparte tu contacto fácilmente")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    // More subtle edit button
                    Button(action: {
                        viewModel.isDataSaved = false
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // QR Card
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.qrPrimary.opacity(0.8))
                        
                        VStack(alignment: .leading) {
                            Text("\(viewModel.userData.firstName) \(viewModel.userData.lastName)")
                                .font(.title2)
                                .bold()
                            Text(viewModel.userData.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if let qrCodeData = viewModel.generateQRCode(),
                       let uiImage = UIImage(data: qrCodeData) {
                        Image(uiImage: uiImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                shareQRCode(image: uiImage)
                            }
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.userData.email ?? "Sin email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 30)
                .background(Color.qrCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
                
                // Scan Button
                Button(action: {
                    viewModel.showingScanner = true
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                        Text("Escanear Nuevo QR")
                            .font(.headline)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .sheet(isPresented: $viewModel.showingScanner) {
                    QRScannerView()
                }
                
                // Delete Button
                Button("Eliminar mis datos", role: .destructive) {
                    viewModel.showAlert = true
                }
                .font(.headline)
                .padding(.bottom)
            }
        }
        .alert("¿Eliminar datos?", isPresented: $viewModel.showAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                viewModel.deleteData()
            }
        } message: {
            Text("Esta acción borrará tu tarjeta y no se puede deshacer.")
        }
        .tint(.qrPrimary)
        .colorScheme(.light)
    }
    
    func shareQRCode(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
