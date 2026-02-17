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
            Form {
                Section(header: Text("Información de Contacto")) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("\(contact.givenName) \(contact.familyName)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if !contact.organizationName.isEmpty {
                                Text(contact.organizationName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Detalles")) {
                    if !contact.phoneNumbers.isEmpty {
                        let firstPhone = contact.phoneNumbers[0]
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text(firstPhone.value.stringValue)
                        }
                    }
                    
                    if !contact.emailAddresses.isEmpty {
                        let firstEmail = contact.emailAddresses[0]
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text(firstEmail.value as String)
                        }
                    }
                }
                
                Section {
                    Button(action: saveContact) {
                        HStack {
                            Spacer()
                            Text("Guardar en Contactos")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
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
