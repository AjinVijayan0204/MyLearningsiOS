//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Ajin on 20/02/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database(url: "https://messenger-340bd-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    
}

// MARK: - Account management

extension DatabaseManager{
    
    ///check email exists or not
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard let _ = snapshot.value as? String else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///Inserts new user to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName])
    }
}
struct ChatAppUser{
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
}
