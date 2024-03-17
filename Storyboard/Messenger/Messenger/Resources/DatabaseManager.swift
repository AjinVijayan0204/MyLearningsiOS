//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Ajin on 20/02/24.
//

import Foundation
import FirebaseDatabase
import MessageKit
import UIKit
import CoreLocation

final class DatabaseManager{
    
    public static let shared = DatabaseManager()
    private let database = Database.database(url: "https://messenger-340bd-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    private init(){}
    
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
        var safeEmail = DatabaseManager.getSafeEmail(email: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String: Any] != nil else{
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
            "last_name": user.lastName]) { [weak self]error, databaseRef in
                guard let strongSelf = self else{
                    return
                }
                guard error == nil else{
                    print("failed to write to DB")
                    completion(false)
                    return
                }
                strongSelf.database.child("users").observeSingleEvent(of: .value) { snapshot  in
                    if var userCollection = snapshot.value as? [[String: String]]{
                        let newCollection: [[String: String]] = [
                            ["name": user.firstName + " " + user.lastName,
                             "email": user.safeEmail]
                        ]
                        userCollection.append(contentsOf: newCollection)
                        strongSelf.database.child("users").setValue(userCollection) { error, _ in
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
                        strongSelf.database.child("users").setValue(newCollection) { error, _ in
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
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else{
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
                        "isRead": false
                    ] as [String : Any]
            ]
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "isRead": false
                    ] as [String : Any]
            ]
            //update receipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String: Any]]{
                    conversations.append(recipient_newConversationData)
                    let usernode = conversations
                    self?.database.child("\(otherUserEmail)/conversations").setValue(usernode)
                }else{
                    let usernode = [recipient_newConversationData ]
                    self?.database.child("\(otherUserEmail)/conversations").setValue(usernode)
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
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                }
            }
            self?.finishCreatingConversation(name: name,
                                             conversationID: conversationId,
                                             firstMessage: firstMessage,
                                             completion: completion)
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
            "isRead": false,
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
                      let isRead = latestMessage["isRead"] as? Bool else{
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
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                let date = ChatViewController.dateFormatter.date(from: dateString) else{
                    return nil
                }
                var kind: MessageKind?
                if type == "photo"{
                    guard let imageUrl = URL(string: content),
                    let placeholder = UIImage(systemName: "photo") else {
                        return nil
                    }
                    let media = Media(url: imageUrl, placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }else if type == "video"{
                    guard let videoUrl = URL(string: content),
                          let placeholder = UIImage(systemName: "play.fill") else {
                        return nil
                    }
                    let media = Media(url: videoUrl, placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }else if type == "location"{
                    let locationComponent = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponent[0]),
                          let latitude = Double(locationComponent[1]) else{
                        return nil
                    }
                    
                    let location = Location(location: CLLocation(latitude: latitude,
                                                                 longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                else{
                    kind = MessageKind.text(content)
                }
                
                guard let finalKind = kind else{
                    return nil
                }
                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            }
            completion(.success(messages))
        }
    }

    ///sends  a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail:String, name: String, newMessage: Message, completion: @escaping (Bool)-> Void){
        
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self]snapshot in
            print("Trying to send")
            guard let strongSelf = self else{
                completion(false)
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else{
                print("Failing to send")
                completion(false)
                return
            }
            print("Trying to send2")
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString{
                    message = targetUrl
                }
                break
            case .video(let mediaItem):
                if let targetUrl = mediaItem.url?.absoluteString{
                    message = targetUrl
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
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
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.description,
                "content": message,
                "date": dateString,
                "sender_email": safeCurrentEmail,
                "isRead": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                strongSelf.database.child("\(safeCurrentEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue = [
                        "date": dateString,
                        "message": message,
                        "isRead": false
                    ] as [String : Any]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var position = 0
                        var targetConversation: [String: Any]?
                        for currentUserConversation in currentUserConversations {
                            if let currentId = currentUserConversation["id"] as? String,
                               currentId == conversation{
                                targetConversation = currentUserConversation
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation{
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }else{
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.getSafeEmail(email: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }else{
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.getSafeEmail(email: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    
                    strongSelf.database.child("\(safeCurrentEmail)/conversations").setValue(databaseEntryConversations) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        //update latest message for receipient
                        let safeOtherUserEmail = DatabaseManager.getSafeEmail(email: otherUserEmail)
                        strongSelf.database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                            let updatedValue: [String : Any] = [
                                "date": dateString,
                                "message": message,
                                "isRead": false
                            ]
                            var databaseEntryConversations = [[String: Any]]()
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else{
                                return
                            }
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var position = 0
                                var targetConversation: [String: Any]?
                                for otherUserConversation in otherUserConversations {
                                    if let currentId = otherUserConversation["id"] as? String,
                                       currentId == conversation{
                                        targetConversation = otherUserConversation
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation{
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }else{
                                    //failed to find current collection
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.getSafeEmail(email: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                                
                            }else{
                                // current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.getSafeEmail(email: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            
                            strongSelf.database.child("\(safeOtherUserEmail)/conversations").setValue(databaseEntryConversations) { error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            })
        }
    }
}

extension DatabaseManager{
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>)-> Void){
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool)-> Void){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: email)
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]]{
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId{
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations) { error, _ in
                    guard error == nil else{
                        completion(false)
                        print("Failed to write in conv")
                        return
                    }
                    print("Deleted conversaton")
                    completion(true)
                }
            }
        }
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>)-> Void){
        let safeRecipientEmail = DatabaseManager.getSafeEmail(email: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeSenderEmail = DatabaseManager.getSafeEmail(email: senderEmail)
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            if let conversation = collection.first(where: { conv in
                guard let targetSenderEmail = conv["other_user_email"] as? String else{
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }){
                guard let id = conversation["id"] as? String else{
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
        }
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
