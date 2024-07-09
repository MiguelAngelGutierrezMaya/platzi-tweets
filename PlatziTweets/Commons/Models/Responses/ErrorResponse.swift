//
//  ErrorResponse.swift
//  PlatziTweets
//
//  Created by Keybe on 26/03/23.
//

struct ErrorResponse: Codable {
    let error: String
}

struct ErrorApiResponse: Codable {
    let error: ErrorDescription
    let errorType: ErrorType
}

struct ErrorDescription: Codable {
    let name: String
}

struct ErrorType: Codable {
    let statusCode: Int
    let name: String
    let message: String
}
