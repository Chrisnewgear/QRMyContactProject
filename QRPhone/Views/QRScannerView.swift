//
//  QRScannerView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI
import Contacts

struct ContactWrapper: Identifiable {
    let id = UUID()
    let contact: CNMutableContact
}

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scannedCode: String?
    @State private var contactWrapper: ContactWrapper?

    var body: some View {
        ZStack {
            CameraView(scannedCode: $scannedCode)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                Text("Escanea un código QR")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Request permissions immediately when scanner opens
            checkContactsPermission()
        }
        .onChange(of: scannedCode) { newValue in
            if let code = newValue {
                processScannedCode(code)
            }
        }
        .fullScreenCover(item: $contactWrapper, onDismiss: {
            // Reset state to allow scanning again
            scannedCode = nil
            print("🔄 Reset scanner for next scan")
        }) { wrapper in
            ContactViewController(contact: wrapper.contact) {
                // If contact was saved successfully, dismiss the scanner view as well to return to home screen
                print("✅ Contact saved, dismissing scanner view")
                dismiss()
            }
        }
    }
    
    private func checkContactsPermission() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                print("✅ Contacts permission confirmed on appear")
            } else {
                print("❌ Contacts permission check failed: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    private func processScannedCode(_ code: String) {
        print("🔍 Scanned QR Code: \(code)")
        
        let components = code.components(separatedBy: "\n")
        print("📦 Components count: \(components.count)")
        print("📦 Components: \(components)")
        
        guard components.count >= 3 else {
            print("❌ Not enough components. Expected at least 3, got \(components.count)")
            return
        }

        let firstName = components[0]
        let lastName = components[1]
        let phoneNumber = components[2]
        let email = components.count > 3 && !components[3].isEmpty ? components[3] : nil

        print("👤 Creating contact: \(firstName) \(lastName), Phone: \(phoneNumber), Email: \(email ?? "none")")

        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName

        let phoneNumberValue = CNLabeledValue(
            label: CNLabelPhoneNumberMobile,
            value: CNPhoneNumber(stringValue: phoneNumber)
        )
        contact.phoneNumbers = [phoneNumberValue]
        
        // Add email if available
        if let email = email {
            let emailValue = CNLabeledValue(
                label: CNLabelHome,
                value: email as NSString
            )
            contact.emailAddresses = [emailValue]
        }

        // Show the contact details immediately
        contactWrapper = ContactWrapper(contact: contact)
        print("✅ Contact created, showing contact view")
    }
}

#Preview {
    QRScannerView()
}
