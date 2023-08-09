//
//  ContentView.swift
//  playground
//
//  Created by Minyoung Yoo on 2023/08/09.
//

import SwiftUI

struct FakeData: Identifiable, Codable {
    var id: Int
    let userId: Int
    let title: String
    let body: String
}

class FakeDataList: ObservableObject {
    @Published var fakeData: [FakeData] = []
    
    init(){
        
    }
    
    @MainActor func fetchData() async {
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        guard let url = URL(string: urlString) else {
            print("url not found")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode <= 200 else {
                //HTTP 통신 실패했을 경우
                return
            }
            
            //json string이 필요한 경우 사용 (API에서 PHP echo 같은걸로 찍혀서 평문으로 반환될 때...)
//            guard let jsonString = String(data: data, encoding: .utf8) else {
//                print("Json Empty")
//                return
//            }
            
            fakeData = try JSONDecoder().decode([FakeData].self, from: data)
            
        } catch {
            debugPrint("--------")
            debugPrint("Error loading \(url):")
            debugPrint("\(String(describing: error))")
            debugPrint("--------")
        }
    }
}

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @ObservedObject private var fakeDataList: FakeDataList = FakeDataList()
    
    var body: some View {
        List(fakeDataList.fakeData){ fData in
            VStack{
                Text("\(fData.title)")
                    .font(.system(.headline))
            }
        }
        .task {
            await fakeDataList.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
