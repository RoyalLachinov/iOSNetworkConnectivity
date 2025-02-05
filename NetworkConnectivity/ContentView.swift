//
//  ContentView.swift
//  NetworkConnectivity
//
//  Created by Royal Lachinov on 2025-02-02.
//

import SwiftUI

struct ContentView: View {
    
    @State private var gitUser: GithubUser?
    
    var body: some View {
        VStack(spacing: 20) {
        
            AsyncImage(url: URL(string: gitUser?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                
            } placeholder: {
                Circle()
                    .fill(Color.secondary)
            }
            .frame(width: 100, height: 100)
            
            Text(gitUser?.login ?? "Login placeholder")
                .bold()
                .font(.caption)
            
            Text(gitUser?.bio ?? "Bio placeholder")
            
            Spacer()
        }
        .padding()
        .task {
            do {
                self.gitUser = try await getUser()
            } catch  ErrorHandler.invalidURL {
                print("Invalid UrL")
            } catch ErrorHandler.invalidResponse {
                print("Invalid Response")
            } catch ErrorHandler.invalidData {
                print("Invalid Data")
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func getUser() async throws -> GithubUser {
        let endPoint = "https://api.github.com/users/RoyalLachinov"
        
        guard let url = URL(string: endPoint) else {
            throw ErrorHandler.invalidURL
        }
        // data is json data
        // response is HTTPURLResponse
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ErrorHandler.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            //snake_case: my_variable_name
            //camelCase: myVariableName
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw ErrorHandler.invalidData
        }
    }
}

struct GithubUser : Codable { //Identifiable, Decodable,
    let login: String
    let avatarUrl: String
    let bio: String
}

enum ErrorHandler : Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
