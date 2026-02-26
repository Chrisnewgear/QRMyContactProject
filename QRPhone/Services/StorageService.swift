//
//  StorageService.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import Foundation
import Security

/// Stores sensitive user PII in the iOS Keychain (AES-256 encrypted at rest)
/// instead of UserDefaults (plain-text plist).
class StorageService {

    // MARK: - Keychain Keys
    private enum Key: String {
        case firstName  = "qrphone.user.firstName"
        case lastName   = "qrphone.user.lastName"
        case phone      = "qrphone.user.phone"
        case email      = "qrphone.user.email"
    }

    // MARK: - Public API

    func saveData(_ userData: UserData) {
        set(userData.firstName,        for: .firstName)
        set(userData.lastName,         for: .lastName)
        set(userData.phoneNumber,      for: .phone)
        set(userData.email ?? "",      for: .email)
    }

    func loadData() -> UserData {
        let firstName   = get(.firstName)   ?? ""
        let lastName    = get(.lastName)    ?? ""
        let phone       = get(.phone)       ?? ""
        let rawEmail    = get(.email)       ?? ""
        let email: String? = rawEmail.isEmpty ? nil : rawEmail
        return UserData(phoneNumber: phone, firstName: firstName, lastName: lastName, email: email)
    }

    func deleteData() {
        delete(.firstName)
        delete(.lastName)
        delete(.phone)
        delete(.email)
    }

    // MARK: - Keychain Helpers

    private func set(_ value: String, for key: Key) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete any existing item first
        let deleteQuery: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add the new item with .whenUnlocked protection
        let addQuery: [CFString: Any] = [
            kSecClass:                kSecClassGenericPassword,
            kSecAttrAccount:          key.rawValue,
            kSecValueData:            data,
            kSecAttrAccessible:       kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            print("⚠️ Keychain write failed (status \(status))")
        }
    }

    private func get(_ key: Key) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key.rawValue,
            kSecReturnData:       kCFBooleanTrue!,
            kSecMatchLimit:       kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    private func delete(_ key: Key) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
