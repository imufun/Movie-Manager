//
//  RequestTokenResponse.swift
//  TheMovieManager
//
 
import Foundation

struct RequestTokenResponse : Codable {
    let success : Bool
    let expiresAT : String
    let requestToken : String
    
    enum CodingKeys : String, CodingKey {
        case success
        case expiresAT = "expires_at"
        case requestToken = "request_token"
    }
}
