//
//  StorageManager.swift
//  Messenger
//
//  Created by Ajin on 27/02/24.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage(url: "gs://messenger-340bd.appspot.com").reference()
    
    /*
     format - /images/email.png
     */
    /// uploads picture to firebase storage and returns completion with url string to download
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(filename)").putData(data) { metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(filename)").downloadURL { url, error in
                guard let url = url else{
                    print("Error in loading url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>)-> Void){
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    
    ///upload image that will be sent as a conversation message
    public func uploadMessagePhoto(with data: Data, filename: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(filename)").putData(data) { [weak self]metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("message_images/\(filename)").downloadURL { url, error in
                guard let url = url else{
                    print("Error in loading url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    ///upload video that will be sent as a conversation message
    public func uploadMessageVideo(with fileUrl: URL, filename: String, completion: @escaping UploadPictureCompletion){
        
        do{
            let data = try Data(contentsOf: fileUrl)
            let metaData = StorageMetadata()
            metaData.contentType = "video/mp4"
            storage.child("message_videos/\(filename)").putData(data, metadata: metaData) { [weak self] metadata, error in
                guard error == nil else {
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                self?.storage.child("message_videos/\(filename)").downloadURL { url, error in
                    guard let url = url else{
                        print("Error in loading url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    let urlString = url.absoluteString
                    print("download url returned: \(urlString)")
                    completion(.success(urlString))
                }
            }
            
        }catch{
            completion(.failure(StorageErrors.failedToUpload))
            return
        }
        
    }
}
