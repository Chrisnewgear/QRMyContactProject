//
//  StorageService.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import Foundation

class StorageService{
    private let defaults = UserDefaults.standard
    private let nameKey = "userName"
    private let lastName = "userLastName"
    private let phoneKey = "userPhone"
    private let emailKey = "userEmail"
    
    func saveData(_ userData: UserData){
        defaults.set(userData.firstName, forKey: nameKey)
        defaults.set(userData.lastName, forKey: lastName)
        defaults.set(userData.phoneNumber, forKey: phoneKey)
        defaults.set(userData.email, forKey: emailKey)
    }
    
    
    func loadData() -> UserData {
        let name = defaults.string(forKey: nameKey) ?? ""
        let lastName = defaults.string(forKey: lastName) ?? ""
        let phone = defaults.string(forKey: phoneKey) ?? ""
        let email = defaults.string(forKey: emailKey)
        return UserData(phoneNumber: phone, firstName: name, lastName: lastName, email: email)
    }
    
    func deleteData(){
        defaults.removeObject(forKey: nameKey)
        defaults.removeObject(forKey: lastName)
        defaults.removeObject(forKey: phoneKey)
        defaults.removeObject(forKey: emailKey)
    }
}
