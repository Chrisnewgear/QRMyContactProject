//
//  UserDataViewModel.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import Foundation
import Combine

class UserDataViewModel: ObservableObject{
    @Published var userData: UserData
    @Published var showAlert = false
    @Published var showingScanner = false
    @Published var isDataSaved = false
    
    
    private let storageService: StorageService
    private let qrCodeService: QRCodeService
    
    
    init(storageService: StorageService = StorageService(),
         qrCodeService: QRCodeService = QRCodeService()){
        self.storageService = storageService
        self.qrCodeService = qrCodeService
        self.userData = storageService.loadData()
        // Check if we have saved data on init
        self.isDataSaved = !userData.phoneNumber.isEmpty && !userData.firstName.isEmpty && !userData.lastName.isEmpty
    }
    
    var hasData: Bool{
        !userData.phoneNumber.isEmpty && !userData.firstName.isEmpty && !userData.lastName.isEmpty
    }
    
    func saveData(){
        storageService.saveData(userData)
        isDataSaved = true
    }
    
    func deleteData() {
        userData = UserData(phoneNumber: "", firstName: "", lastName: "", email: nil)
        storageService.deleteData()
        isDataSaved = false
    }

    func generateQRCode() -> Data? {
        qrCodeService.generateQRCode(from: userData.phoneNumber)
    }
    
}
