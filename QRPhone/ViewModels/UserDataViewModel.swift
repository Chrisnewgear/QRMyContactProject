//
//  UserDataViewModel.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import Foundation
import Combine

class UserDataViewModel: ObservableObject {
    @Published var userData: UserData
    @Published var showAlert = false
    @Published var showingScanner = false
    @Published var isDataSaved = false
    @Published var validationError: String? = nil

    private let storageService: StorageService
    private let qrCodeService: QRCodeService

    init(storageService: StorageService = StorageService(),
         qrCodeService: QRCodeService = QRCodeService()) {
        self.storageService = storageService
        self.qrCodeService = qrCodeService
        self.userData = storageService.loadData()
        self.isDataSaved = !userData.phoneNumber.isEmpty && !userData.firstName.isEmpty && !userData.lastName.isEmpty
    }

    var hasData: Bool {
        !userData.phoneNumber.isEmpty && !userData.firstName.isEmpty && !userData.lastName.isEmpty
    }

    // MARK: - Sanitization & Validation

    private func sanitize(_ value: String, maxLength: Int = 100) -> String {
        String(value.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength))
    }

    private func isValidPhone(_ phone: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "+0123456789 ()-")
        return !phone.isEmpty && phone.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    // MARK: - Save

    func saveData() {
        // Sanitize all fields before saving
        let firstName   = sanitize(userData.firstName)
        let lastName    = sanitize(userData.lastName)
        let phoneNumber = sanitize(userData.phoneNumber, maxLength: 20)
        let rawEmail    = sanitize(userData.email ?? "", maxLength: 254)

        guard !firstName.isEmpty, !lastName.isEmpty else {
            validationError = "El nombre no puede estar vacío."
            return
        }

        guard isValidPhone(phoneNumber) else {
            validationError = "El número de teléfono contiene caracteres inválidos."
            return
        }

        var validatedEmail: String? = nil
        if !rawEmail.isEmpty {
            guard isValidEmail(rawEmail) else {
                validationError = "El formato del email no es válido."
                return
            }
            validatedEmail = rawEmail
        }

        validationError = nil
        userData = UserData(phoneNumber: phoneNumber, firstName: firstName, lastName: lastName, email: validatedEmail)
        storageService.saveData(userData)
        isDataSaved = true
    }

    // MARK: - Delete

    func deleteData() {
        userData = UserData(phoneNumber: "", firstName: "", lastName: "", email: nil)
        storageService.deleteData()
        isDataSaved = false
    }

    // MARK: - QR Generation

    func generateQRCode() -> Data? {
        // Use sanitized, validated stored data only — never raw @Published fields
        let qrData = "\(userData.firstName)\n\(userData.lastName)\n\(userData.phoneNumber)\n\(userData.email ?? "")"
        return qrCodeService.generateQRCode(from: qrData)
    }
}
