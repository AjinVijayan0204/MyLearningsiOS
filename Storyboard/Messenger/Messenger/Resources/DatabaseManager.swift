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
    
    static func getSafeEmail(email: String)-> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    
    
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
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName]) { error, databaseRef in
                guard error == nil else{
                    print("failed to write to DB")
                    completion(false)
                    return
                }
                self.database.child("users").observeSingleEvent(of: .value) { snapshot  in
                    if var userCollection = snapshot.value as? [[String: String]]{
                        let newCollection: [[String: String]] = [
                            ["name": user.firstName + " " + user.lastName,
                             "email": user.safeEmail]
                        ]
                        userCollection.append(contentsOf: newCollection)
                        self.database.child("users").setValue(userCollection) { error, _ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                        
                    }else{
                        let newCollection: [[String: String]] = [
                            ["name": user.firstName + " " + user.lastName,
                             "email": user.safeEmail]
                        ]
                        self.database.child("users").setValue(newCollection) { error, _ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
        case fetchedErrorValues
    }
}

//MARK: - Sending messages
extension DatabaseManager{
    
    /*
        "id"{
            "messages" : [
                { id: String,
                    type: text, photo, video,
                    content: String,
                    date: Date(),
                    sender email: String,
                    isRead: true/false,
            ]
        }
        conversation => [
        [
            "conversation_id":
            "other_user email":
            "latest message": => {
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
            }
        ]
     ]
     */
    ///create a new conversation with target user
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: currentEmail)
        let ref =  database.child(safeEmail)
        ref.observeSingleEvent(of: .value) { [weak self]snapshot in
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_ read": false
                    ] as [String : Any]
            ]
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": "Self",
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_ read": false
                    ] as [String : Any]
            ]
            //update receipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String: Any]]{
                    conversations.append(recipient_newConversationData)
                    print("exists")
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else{
                    self?.database.child("\(otherUserEmail)/conversations").setValue(recipient_newConversationData)
                }
            }
            // update current user conversation
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                //conversation exists and need to append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }else{
                // add new convo
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { [weak self]error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let safeCurrentEmail = DatabaseManager.getSafeEmail(email: currentEmail)
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.description,
            "content": message,
            "date": dateString,
            "sender_email": safeCurrentEmail,
            "is_read": false,
            "name": name
        ]
        let value: [String: Any] = [
            "messages":[ collectionMessage ]
        ]
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    ///fetches and returns old conversation for the user with passed email
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>)-> Void){
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                let otherUserEmail = dictionary["other_user_email"] as? String,
                let name = dictionary["name"] as? String,
                let latestMessage = dictionary["latest_message"] as? [String: Any],
                let date = latestMessage["date"] as? String,
                let message = latestMessage["message"] as? String,
                let isRead = latestMessage["is_ read"] as? Bool else{
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
    }
    
    ///gats all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>)-> Void){
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                let date = ChatViewController.dateFormatter.date(from: dateString) else{
                    return nil
                }
                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
            }
            completion(.success(messages))
        }
    }

    ///sends  a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message){
        
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
    
    var profilePictureName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}
