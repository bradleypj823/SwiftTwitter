//
//  Tweet.swift
//  Swift-Twitter
//
//  Created by Bradley Johnson on 9/16/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation


class Tweet {
    
    let text : String
    let id : Int
    let createdAt : String
    let userName : String
    let retweetCount : Int
    let favoritesCount : Int
    let profileImgURL : String
    
    init(jsonDictionary : NSDictionary) {
        self.text = jsonDictionary["text"] as String
        self.id = jsonDictionary["id"] as Int
        println(jsonDictionary["id"])
        self.createdAt = jsonDictionary["created_at"] as String
        self.retweetCount = jsonDictionary["retweet_count"] as Int
        //if the json we got back contains favorite counts for each tweet, use that data to set the favoritesCount property. If not, set it to 0
        if let favoritesCount = jsonDictionary["favorite_count"] as? Int {
            self.favoritesCount = favoritesCount
        } else {
            self.favoritesCount = 0
        }
        //self.favoritesCount = jsonDictionary["favourites_count"] as Int
        let userDictionary = jsonDictionary["user"] as NSDictionary
        self.userName = userDictionary["name"] as String
        self.profileImgURL = userDictionary["profile_image_url"] as String
    }
}