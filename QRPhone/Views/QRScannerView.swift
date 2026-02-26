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
    @State private var showInvalidQRAlert = false

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
        .alert("Código QR invalido", isPresented: $showInvalidQRAlert){
            Button("OK", role: .cancel) {}
        }message: {
            Text("Este código QR no contiene información de contacto válida.")
        }
    }
    
    private func checkContactsPermission() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        // Only request access if the user hasn't been asked yet
        guard status == .notDetermined else { return }
        CNContactStore().requestAccess(for: .contacts) { _, _ in }
    }

    // MARK: - Input Sanitization & Validation

    /// Trims whitespace/newlines and enforces a maximum character length.
    private func sanitize(_ input: String, maxLength: Int = 100) -> String {
        String(input.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength))
    }

    /// Allows only characters valid in a phone number: digits, +, spaces, (, ), -.
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "+0123456789 ()-")
        return !phone.isEmpty && phone.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    /// RFC 5321/5322 email format check.
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    // MARK: - QR Processing

    private func processScannedCode(_ code: String) {
        // Do NOT log raw QR content — it contains PII
        print("🔍 QR code received, processing...")

        // Reject excessively long payloads before any further processing
        guard code.count <= 500 else {
            print("❌ QR payload exceeds maximum allowed length")
            showInvalidQRAlert = true
            scannedCode = nil
            return
        }

        let components = code.components(separatedBy: "\n")

        guard components.count >= 3 else {
            print("❌ QR payload has too few fields (\(components.count))")
            showInvalidQRAlert = true
            scannedCode = nil
            return
        }

        let firstName   = sanitize(components[0])
        let lastName    = sanitize(components[1])
        let phoneNumber = sanitize(components[2], maxLength: 20)

        guard !firstName.isEmpty, !lastName.isEmpty else {
            print("❌ Name fields are empty after sanitization")
            showInvalidQRAlert = true
            scannedCode = nil
            return
        }

        guard isValidPhoneNumber(phoneNumber) else {
            print("❌ Phone number failed validation")
            showInvalidQRAlert = true
            scannedCode = nil
            return
        }

        var validatedEmail: String? = nil
        if components.count > 3 {
            let rawEmail = sanitize(components[3], maxLength: 254)
            if !rawEmail.isEmpty {
                guard isValidEmail(rawEmail) else {
                    print("❌ Email failed validation")
                    showInvalidQRAlert = true
                    scannedCode = nil
                    return
                }
                validatedEmail = rawEmail
            }
        }

        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        contact.phoneNumbers = [
            CNLabeledValue(label: CNLabelPhoneNumberMobile,
                           value: CNPhoneNumber(stringValue: phoneNumber))
        ]
        if let email = validatedEmail {
            contact.emailAddresses = [
                CNLabeledValue(label: CNLabelHome, value: email as NSString)
            ]
        }

        contactWrapper = ContactWrapper(contact: contact)
        print("✅ Contact created successfully")
    }
}

#Preview {
    QRScannerView()
}
