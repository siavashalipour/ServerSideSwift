//
//  MongoDBService.swift
//  UserAPI
//
//  Created by Siavash on 9/4/18.
//

import MongoKitten

struct MongoDataBaseService {
    
    let myDatabase: Database?
    
    init() {
        myDatabase = try? MongoKitten.Database("mongodb://localhost/UserAPI")
    }
    
    func getCollection() -> MongoKitten.Collection? {
        guard let db = myDatabase else { return nil }
        return db["Users"]
    }
}

