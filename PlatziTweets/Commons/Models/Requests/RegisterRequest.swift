//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Keybe on 20/04/23.
//

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let names: String
    let lastnames: String
    let nickname: String
}
