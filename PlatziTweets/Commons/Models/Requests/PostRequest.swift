//
//  PostRequest.swift
//  PlatziTweets
//
//  Created by Keybe on 20/04/23.
//

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: PostRequestLocation?
}
