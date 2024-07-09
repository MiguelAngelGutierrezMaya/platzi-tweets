//
//  RegisterResponse.swift
//  PlatziTweets
//
//  Created by Keybe on 29/04/23.
//

struct RegisterResponse: Codable {
    let user: User
    let token: String
}
