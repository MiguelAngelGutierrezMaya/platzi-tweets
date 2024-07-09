//
//  Post.swift
//  PlatziTweets
//
//  Created by Keybe on 20/04/23.
//

struct Post: Codable {
    let id: String
    let author: User
    let imageUrl: String?
    let text: String
    let videoUrl: String?
    let location: PostLocation?
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String?
}

struct PostQueryResponse: Codable {
    var posts: [Post]
}
