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
                        .foregroundColor(.white)
                    
                    Text("Crea tu código QR")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Tus datos se codificarán en un QR para que otros puedan escanearte fácilmente.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(icon: "person.fill", title: "Nombre", text: $viewModel.userData.firstName)
                        .focused($focusedField, equals: .firstName)
                        .onChange(of: viewModel.userData.firstName) { v in
                            if v.count > 100 { viewModel.userData.firstName = String(v.prefix(100)) }
                        }

                    CustomTextField(icon: "person.fill", title: "Apellido", text: $viewModel.userData.lastName)
                        .focused($focusedField, equals: .lastName)
                        .onChange(of: viewModel.userData.lastName) { v in
                            if v.count > 100 { viewModel.userData.lastName = String(v.prefix(100)) }
                        }

                    CustomTextField(icon: "phone.fill", title: "Número de teléfono", text: $viewModel.userData.phoneNumber, keyboardType: .numberPad)
                        .focused($focusedField, equals: .phoneNumber)
                        .onChange(of: viewModel.userData.phoneNumber) { v in
                            if v.count > 20 { viewModel.userData.phoneNumber = String(v.prefix(20)) }
                        }

                    CustomTextField(icon: "envelope.fill", title: "Email (opcional)", text: Binding(
                        get: { viewModel.userData.email ?? "" },
                        set: { viewModel.userData.email = $0.isEmpty ? nil : $0 }
                    ), keyboardType: .emailAddress)
                        .focused($focusedField, equals: .email)
                        .onChange(of: viewModel.userData.email ?? "") { v in
                            if v.count > 254 { viewModel.userData.email = String(v.prefix(254)) }
                        }
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

                if let error = viewModel.validationError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
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
                .tint(.qrDeepBlue)
                .if(keyboardType == .emailAddress) { view in
                    view.textInputAutocapitalization(.never)
                }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
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
