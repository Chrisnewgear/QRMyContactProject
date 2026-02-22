//
//  ContactViewController.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 17/2/26.
//

import SwiftUI
import Contacts
import ContactsUI

// Rename struct to match existing usage in QRScannerView but implement as pure SwiftUI
struct ContactViewController: View {
    let contact: CNMutableContact
    var onSave: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.qrBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Contact Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                        
                        VStack(spacing: 4) {
                            Text("\(contact.givenName) \(contact.familyName)")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if !contact.organizationName.isEmpty {
                                Text(contact.organizationName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Details Card
                    VStack(alignment: .leading, spacing: 20) {
                        if !contact.phoneNumbers.isEmpty {
                            HStack(spacing: 16) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Móvil")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(contact.phoneNumbers[0].value.stringValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        
                        if !contact.emailAddresses.isEmpty {
                            Divider()
                            
                            HStack(spacing: 16) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(contact.emailAddresses[0].value as String)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.qrCard)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: saveContact) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Guardar en Contactos")
                                .fontWeight(.bold)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Nuevo Contacto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveContact()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Contacto Guardado" {
                            dismiss()
                            onSave?()
                        }
                    }
                )
            }
        }
    }
    
    func saveContact() {
        let store = CNContactStore()
        
        // 1. Request Permission
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Check for duplicate phone number
                    do {
                        if let phoneNumber = self.contact.phoneNumbers.first?.value {
                            let predicate = CNContact.predicateForContacts(matching: phoneNumber)
                            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
                            
                            let existingContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                            
                            if !existingContacts.isEmpty {
                                let existing = existingContacts[0]
                                self.alertTitle = "Contacto Existente"
                                self.alertMessage = "Este número ya está guardado como: \(existing.givenName) \(existing.familyName)"
                                self.showingAlert = true
                                return
                            }
                        }
                    } catch {
                        print("Error checking duplicates: \(error.localizedDescription)")
                    }

                    // 2. Save Contact
                    let saveRequest = CNSaveRequest()
                    saveRequest.add(contact, toContainerWithIdentifier: nil)
                    
                    do {
                        try store.execute(saveRequest)
                        alertTitle = "Contacto Guardado"
                        alertMessage = "El contacto se ha guardado correctamente en tu iPhone."
                        showingAlert = true
                    } catch {
                        alertTitle = "Error"
                        alertMessage = "No se pudo guardar el contacto: \(error.localizedDescription)"
                        showingAlert = true
                    }
                } else {
                    // Permission Denied
                    alertTitle = "Permiso Necesario"
                    alertMessage = "Para guardar este contacto, necesitas permitir el acceso a Contactos en Configuración -> QRPhone."
                    showingAlert = true
                }
            }
        }
    }
}
