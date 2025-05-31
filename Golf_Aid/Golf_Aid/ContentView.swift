//
//  ContentView.swift
//  Golf_Aid
//
//  Created by DeWitt Colvin on 5/19/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Auth Example")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])
            
            HStack {
                Button("Log In") {
                    sendAuthRequest(to: "login")
                }
                .padding()
                
                Button("Sign Up") {
                    sendAuthRequest(to: "signup")
                }
                .padding()
            }

            Text(message)
                .foregroundColor(.gray)
        }
    }
    
    func sendAuthRequest(to endpoint: String) {
        guard let url = URL(string: "http://192.168.68.64:5070/\(endpoint)") else {
            message = "Invalid URL"
            return
        }

        let body: [String: String] = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            message = "Encoding error"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    message = "No response"
                }
                return
            }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = result["success"] as? Bool {
                DispatchQueue.main.async {
                    message = success ? "✅ Success!" : "❌ \(result["error"] ?? "Unknown error")"
                }
            } else {
                DispatchQueue.main.async {
                    message = "❌ Failed to decode response"
                }
            }
        }.resume()
    }
}


#Preview {
    ContentView()
}
