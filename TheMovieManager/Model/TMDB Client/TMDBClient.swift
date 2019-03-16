//
//  TMDBClient.swift
//  TheMovieManager
//

import Foundation

class TMDBClient {
    
    static let apiKey = "de05a59a85ef1e7797de8d4a6d343d0e"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case login
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"            
            case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // POST: LOGIN
    class func login(username: String, password: String, completion: @escaping(Bool, Error?)-> Void) {
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do {
                let decoder =  JSONDecoder()
                let requestObject = try! decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = requestObject.requestToken
                completion(true, nil)
                
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    
    
    
    // GET REQUEST TOKEN
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { (data, response, error) in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = responseObject.requestToken
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
        task.resume()
        
    }
    
    
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
}
