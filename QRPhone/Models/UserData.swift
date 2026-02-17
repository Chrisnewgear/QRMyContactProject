//
//  UsserData.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import Foundation

struct UserData: Codable{
    var phoneNumber: String
    var firstName: String
    var lastName: String
    var email: String?
    
    var fullName: String{
        "\(firstName) \(lastName)"
    }
}
