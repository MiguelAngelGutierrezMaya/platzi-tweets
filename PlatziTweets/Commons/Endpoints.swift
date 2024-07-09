//
//  Endpoints.swift
//  PlatziTweets
//
//  Created by Keybe on 26/03/23.
//

struct Endpoints {
    static let domain = "https://cdvzntyfre.execute-api.us-east-1.amazonaws.com/prod"
    static let login = Endpoints.domain + "/auth"
    static let register = Endpoints.domain + "/users"
    static let posts = Endpoints.domain + "/posts"
    static let files = Endpoints.domain + "/files"
}
