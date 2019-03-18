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
        case createSessionId
        case webAuth
        
        var stringValue: String {
            switch self {
                case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
                case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                case .createSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                case .webAuth: return  "https://www.themoviedb.org/authenticate" + Auth.requestToken + "?redirect_to=themovieManager:authenticate"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url:URL, response: ResponseType.Type, completion: @escaping(ResponseType?, Error?)-> Void){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data) 
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil , error)
                } 
                
            }
        }
        task.resume()
    }
    
    
    
    
    
    // POST: LOGIN
    class func login(username: String, password: String, completion: @escaping(Bool, Error?)-> Void) {
        var request = URLRequest(url: Endpoints.login.url)
        print("login url----\(request)")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        
        print("body---\(body)")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do {
                let decoder =  JSONDecoder()
                let requestObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = requestObject.requestToken
                completion(true, nil)
                
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    
    class func sessionId (comletion: @escaping(Bool, Error?) -> Void){
        
        var request = URLRequest(url: Endpoints.createSessionId.url)
        print(request)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostSession( requestToken : Auth.requestToken)
        
        request.httpBody = try! JSONEncoder().encode(body)
        
        print("sessionId----\(body)")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                comletion(false, error?.localizedDescription as! Error)
                return
            }
            do {
                let decode = JSONDecoder()
                let responseObject = try decode.decode(SessionResponse.self, from: data)
                 Auth.sessionId = responseObject.sessionId
                print("responseObject-------\(responseObject) \( Auth.sessionId)")
                comletion(true, nil)
            } catch {
                comletion(false, error.localizedDescription as! Error)
            }
        }
        task.resume()
    }
    
    
    
    // GET REQUEST TOKEN
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void){
        
        taskForGetRequest(url: Endpoints.getRequestToken.url, response: RequestTokenResponse.self) { (response, error) in
            if let response  = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
        
    }
    
    
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskForGetRequest(url: Endpoints.getWatchlist.url, response: MovieResults.self) { (response, error) in
            if let response  = response {
              completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
}
