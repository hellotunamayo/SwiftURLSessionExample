//
//  SecondMethodView.swift
//  SwiftURLSessionExample
//
//  Created by Minyoung Yoo on 2023/08/11.
//

import SwiftUI

struct UserData: Identifiable, Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: UserAddress
    let phone: String
    let website: String
    let company: UserCompany
}

struct UserAddress: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: UserCoords
}

struct UserCompany: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
}

struct UserCoords: Codable {
    let lat: String
    let lng: String
}

class UserDataViewModel: ObservableObject {
    @Published var userData: [UserData] = []
    
    init(){
        getUserData()
    }
    
    func getUserData() -> Void {
        //Fake json data from https://jsonplaceholder.typicode.com/users
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        downloadJsonData(fromURL: url) { downloadedData in
            if let data = downloadedData {
                let decoder: JSONDecoder = JSONDecoder()
                guard let parsedUserData = try? decoder.decode([UserData].self, from: data) else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.userData.append(contentsOf: parsedUserData)
                }
            } else {
                print("data downloading error.")
            }
        }
    }
    
    func downloadJsonData(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("no data")
                completionHandler(nil)
                return
            }
            guard error == nil else {
                print("error: \(String(describing: error))")
                completionHandler(nil)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("invalid response")
                completionHandler(nil)
                return
            }

            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("The server returns \(response.statusCode) error.")
                completionHandler(nil)
                return
            }
            
            //or you can shorten "guard let" part like this
//            guard
//                let data = data,
//                error == nil,
//                let response = response as? HTTPURLResponse,
//                response.statusCode >= 200 && response.statusCode < 300 else {
//                print("Data not found or downloading failed.")
//                completionHandler(nil)
//                return
//            }
            
            //for debug
//            print("successfully downloaded data")
//            print(data)
//
//            let jsonString = String(data: data, encoding: .utf8)
//            print(jsonString)
            
            completionHandler(data)

        }.resume()
    }
}

struct SecondMethodView: View{
    
    @StateObject var viewModel: UserDataViewModel = UserDataViewModel()
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(viewModel.userData){ data in
                    VStack(alignment: .leading){
                        NavigationLink {
                            UserDetailView(userData: data)
                        } label: {
                            Text(data.name)
                        }
                    }
                }
            }
            .navigationTitle("Personal Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UserDetailView: View{
    let userData: UserData
    var body: some View{
        List{
            Section("Name") {
                Text(userData.name)
            }
            
            Section("UserName") {
                Text(userData.username)
            }
            
            Section("Phone") {
                Text(userData.phone)
            }
            
            Section("Address") {
                Text("\(userData.address.street), \(userData.address.suite), \(userData.address.city), \(userData.address.zipcode)")
            }
            
            Section("Company") {
                Text(userData.company.name)
            }
            
            Section("Company Catchphrase") {
                Text(userData.company.catchPhrase)
            }
            
            Section("Company BS") {
                Text(userData.company.bs)
            }
        }
        .navigationTitle(userData.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecondMethodView_Previews: PreviewProvider {
    static var previews: some View {
        SecondMethodView()
    }
}
