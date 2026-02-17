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
        VStack(spacing: 20) {
            Text("Ingresa tus datos para generar tu código QR")
                .font(.title2)
                .bold()

            TextField("Nombre", text: $viewModel.userData.firstName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .focused($focusedField, equals: .firstName)
            
            TextField("Apellido", text: $viewModel.userData.lastName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .focused($focusedField, equals: .lastName)
            
            TextField("Número de teléfono", text: $viewModel.userData.phoneNumber)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .focused($focusedField, equals: .phoneNumber)
            
            TextField("Email (opcional)", text: Binding(
                get: { viewModel.userData.email ?? "" },
                set: { viewModel.userData.email = $0.isEmpty ? nil : $0 }
            ))
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .focused($focusedField, equals: .email)

            Button("Guardar y generar QR") {
                focusedField = nil // Dismiss keyboard
                viewModel.saveData()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userData.phoneNumber.isEmpty ||
                     viewModel.userData.firstName.isEmpty ||
                     viewModel.userData.lastName.isEmpty)
        }
        .padding()
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
