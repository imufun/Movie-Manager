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
    
    class func taskForPOSTRequest<RequestType:Encodable, ResponseType: Decodable> (url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping(ResponseType?, Error?)-> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil , error)
                }
                return
            }
             let decoder =  JSONDecoder()
            do {
                let requestObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(requestObject , nil)
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
        let body = LoginRequest(username: username, password: password, requestToken:Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { (response, error) in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(true, nil)
            }
        
        }
    }
    
    
    class func createSessionId (comletion: @escaping(Bool, Error?) -> Void){
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { (response, error) in
            if let response = response {
                Auth.sessionId = response.sessionId
                comletion(true, nil)
            } else {
                comletion(false, error)
            }
        }
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
