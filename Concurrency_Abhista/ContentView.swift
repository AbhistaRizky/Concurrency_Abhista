//
//  ContentView.swift
//  Concurrency_Abhista
//
//  Created by laptop MCO on 07/08/23.
//

import SwiftUI

struct ContentView: View {
    
    private var waifuSearch: [WaifuUser] {
        if searchText.isEmpty{
            return waifu
        } else {
            return waifu.filter { index in
                index.name.lowercased().contains(searchText.lowercased()) || index.anime.lowercased().contains(searchText.lowercased())
            }
        }
    }
    @State private var waifu: [WaifuUser] = []
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List(waifuSearch, id: \.name) { waifuData in
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: waifuData.image)) { phase in
                        VStack {
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else if phase.error != nil {
                                Color.red
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Color.gray
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(waifuData.name)
                            .fontWeight(.bold)
                            .font(.title3)
                        
                        Text(waifuData.anime)
                            .font(.subheadline)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .navigationTitle("Waifu")
            .task {
                do {
                    waifu = try await getWaifu()
                } catch WUError.invalidURL {
                    print("Invalid URL")
                } catch WUError.invalidData {
                    print("Invalid Data")
                } catch WUError.invalidResponse {
                    print("Invalid Response")
                } catch {
                    print("Unexpected Error")
                }
            }
        }
    }
    
    func getWaifu() async throws -> [WaifuUser] {
        let endpoint = "https://waifu-generator.vercel.app/api/v1"
        
        guard let url = URL(string: endpoint) else {
            throw WUError.invalidURL
        }
        
        let (data, response) = try await
        URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw WUError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([WaifuUser].self, from: data)
        } catch {
            throw WUError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
    
    struct WaifuUser: Codable {
        let name: String
        let anime: String
        let image: String
    }
    
    enum WUError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
