//
//  UserModel.swift
//  UserAPI
//
//  Created by Siavash on 9/4/18.
//

import Foundation
import MongoKitten

typealias Codable = Decodable & Encodable

struct UserModel: Codable {
    
    let email: String
    let password: String
    
    func createDocument() -> Document {
        return [UserModelKeys.email: email, UserModelKeys.password: password]
    }
    
    init(from document: Document) {
        self.email = String(document[UserModelKeys.email]) ?? ""
        self.password = String(document[UserModelKeys.password]) ?? ""
    }
}


struct UserModelKeys {
    static let email: String = "email"
    static let password: String = "password"
}
