//
//  PostControllers.swift
//  POST2
//
//  Created by Nathan Andrus on 2/4/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation

class PostController: Codable {
    
    var posts: [Post] = []
    
    private static let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timeQueryStamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        guard let unwrappedURL = PostController.baseURL else { completion(); return }
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { completion(); return }
        //guard let url = PostController.baseURL else { fatalError("URL optional isn't workign")}
        let getterEndPoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndPoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        print(request)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            do {
                guard let data = data else { return }
                let jsonDecoder = JSONDecoder()
                let postDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                let posts = postDictionary.compactMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                print("There was error retreiving from url")
                completion()
                return
            }
            
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping (() -> Void)) {
        let post = Post(username: username, text: text)
        var postData: Data
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch {
            print("Error encoding post")
            completion()
            return
        }
        
        guard let url = PostController.baseURL else { completion(); return }
        let postEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let data = data else { completion(); return }
            let dataAsString = String(data: data, encoding: .utf8)
           
            self.fetchPosts {
            completion()
            }
        }
        dataTask.resume()
    }
}


