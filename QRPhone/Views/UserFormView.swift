//
//  UserFormView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI

struct UserFormView: View {
    @ObservedObject var viewModel: UserDataViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, phoneNumber, email
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.qrGradientStart, .qrGradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("Crea tu código QR")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Text("Tus datos se codificarán en un QR para que otros puedan escanearte fácilmente.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(icon: "person.fill", title: "Nombre", text: $viewModel.userData.firstName)
                        .focused($focusedField, equals: .firstName)
                    
                    CustomTextField(icon: "person.fill", title: "Apellido", text: $viewModel.userData.lastName)
                        .focused($focusedField, equals: .lastName)
                    
                    CustomTextField(icon: "phone.fill", title: "Número de teléfono", text: $viewModel.userData.phoneNumber, keyboardType: .numberPad)
                        .focused($focusedField, equals: .phoneNumber)
                    
                    CustomTextField(icon: "envelope.fill", title: "Email (opcional)", text: Binding(
                        get: { viewModel.userData.email ?? "" },
                        set: { viewModel.userData.email = $0.isEmpty ? nil : $0 }
                    ), keyboardType: .emailAddress)
                        .focused($focusedField, equals: .email)
                }
                .padding()
                .background(Color.qrCard)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // Action Button
                Button(action: {
                    focusedField = nil
                    viewModel.saveData()
                }) {
                    HStack {
                        Text("Guardar y generar QR")
                            .fontWeight(.bold)
                        Image(systemName: "qrcode")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.userData.phoneNumber.isEmpty ||
                         viewModel.userData.firstName.isEmpty ||
                         viewModel.userData.lastName.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .background(Color.qrBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") {
                    focusedField = nil
                }
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .if(keyboardType == .emailAddress) { view in
                    view.textInputAutocapitalization(.never)
                }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
