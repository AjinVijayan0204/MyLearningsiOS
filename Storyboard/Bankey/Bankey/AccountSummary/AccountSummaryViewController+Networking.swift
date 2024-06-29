//
//  AccountSummaryViewController+Networking.swift
//  Bankey
//
//  Created by Ajin on 11/04/24.
//

import Foundation

struct Account: Codable{
    let id: String
    let type: AccountType
    let name: String
    let amount: Decimal
    let createdDateTime: Date
    
    static func makeSkeletion()-> Account{
        return Account(id: "1", type: .Banking, name: "Account name", amount: 0.0, createdDateTime: Date())
    }
}

extension AccountSummaryViewController{
    func fetchAccounts(forUserId userId: String, completion: @escaping (Result<[Account], NetworkingError>)-> Void){
        guard let url = URL(string: "https://fierce-retreat-36855.herokuapp.com/bankey/profile/\(userId)/accounts") else{
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
                    let accounts = try JSONDecoder().decode([Account].self, from: data)
                    completion(.success(accounts))
                }catch{
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
