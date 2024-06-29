//
//  ProfileManager.swift
//  Bankey
//
//  Created by Ajin on 01/05/24.
//

import Foundation

protocol ProfileManageable: AnyObject{
    func fetchProfile(forUserId: String, completion: @escaping (Result<Profile, NetworkingError>)-> Void)
}

enum NetworkingError: Error{
    case serverError
    case decodingError
}

struct Profile: Codable{
    let id: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey{
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

class ProfileManager: ProfileManageable{
    
    func fetchProfile(forUserId userId: String, completion: @escaping (Result<Profile, NetworkingError>)-> Void){
        guard let url = URL(string: "https://fierce-retreat-36855.herokuapp.com/bankey/profile/\(userId)") else{
            completion(.failure(.serverError))
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(.serverError))
                    return
                }
                do{
                    let profile = try JSONDecoder().decode(Profile.self, from: data)
                    completion(.success(profile))
                }catch{
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
