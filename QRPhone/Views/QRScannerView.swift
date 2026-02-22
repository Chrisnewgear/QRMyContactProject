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
            
            // Scanner Overlay
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                // Viewfinder
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [60, 190], dashPhase: 0))
                        .frame(width: 250, height: 250)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [60, 190], dashPhase: 125))
                        .frame(width: 250, height: 250)
                }
                .shadow(color: .black.opacity(0.5), radius: 5)
                
                Text("Escanea un código QR")
                    .font(.headline)
                    .padding()
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.top, 20)
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
