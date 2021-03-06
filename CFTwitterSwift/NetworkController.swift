//
//  NetworkController.swift
//  CFTwitterSwift
//
//  Created by Bradley Johnson on 9/16/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation
import Accounts
import Social
import UIKit


class TwitterNetworkController {
    
    var twitterAccount : ACAccount?
    var imageQueue = NSOperationQueue()
    
    init() {
        //must have init because we have an optional property now?
    }
    
    func fetchUsersHomeTimeLineWithCompletionHandler( completionHandler : ( errorDescription : String?, tweets : [Tweet]? ) -> (Void)) {
        
        //grab reference to the account store on the phone
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        //request access, our completion handler has two parameters, a granted bool, which tells us if the user has allowed us persmission to use their twitter account
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            if granted {
            //time to see if they have any twitter accounts signed in on the phone
            let accounts = accountStore.accountsWithAccountType(accountType)
            if !accounts.isEmpty {
                println("isnt empty")
                //construct our request we are going to send to twitter
               self.twitterAccount = accounts.first as ACAccount?
                var requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                var twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: nil)
                twitterRequest.account = self.twitterAccount
                
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
                    switch httpResponse.statusCode {
                    case 200:
                       println("status code 200!")
                        var tweets = self.parseJSONDataFromTwitter(data)
                       if tweets != nil {
                        completionHandler(errorDescription: nil, tweets: tweets) }
                       else {
                        completionHandler(errorDescription: "oh crap", tweets: nil)
                        }
                    default:
                        println("something didnt work")
                        completionHandler(errorDescription: "something didn't work, please try again", tweets: nil)
                    }
                })
            } else {
                println("please sign on to twitter in your phones settings")
                }
            }
        }
    }
    
    func fetchTweetFromID(id : Int, completionHandler : (errorDescription : String?, tweet : Tweet?) -> (Void)) {
        var requestURL = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json?id=\(id)")
        var twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: nil)
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler { (data, httpResponse, error) -> Void in
            switch httpResponse.statusCode {
            case 200:
                println("status code 200!")
                var tweet = self.parseJSONDataForSingleTweet(data)
                
                if tweet != nil {
                    completionHandler(errorDescription: nil, tweet: tweet) }
                else {
                    completionHandler(errorDescription: "oh crap", tweet: nil)
                }
            default:
                println("something didnt work")
                println(httpResponse.description)
                completionHandler(errorDescription: "something didn't work, please try again", tweet: nil)
            }
        }
    }
    
    func parseJSONDataFromTwitter(data : NSData) -> [Tweet]? {
        var tweets = [Tweet]()
        var error : NSError?
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSArray {
            for JSONObject in JSONArray {
                if let JSONDictionary = JSONObject as? NSDictionary {
                    let tweet = Tweet(jsonDictionary: JSONDictionary)
                    tweets.append(tweet)
                }
            }
             return tweets
        }
       return nil
    }
    
    func parseJSONDataForSingleTweet(data : NSData) -> Tweet? {
        var error : NSError?
        if let JSONDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
                    let tweet = Tweet(jsonDictionary: JSONDictionary)
                    return tweet
            }
            return nil
        }
    
    func fetchUserImageForURL(urlString : String, completionHandler : (image : UIImage) -> (Void)) {
        
        var url = NSURL(string: urlString)
        
        self.imageQueue.addOperationWithBlock { () -> Void in
            var data = NSData(contentsOfURL: url)
            var image = UIImage(data: data)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: image)
            })
        }
    }

}