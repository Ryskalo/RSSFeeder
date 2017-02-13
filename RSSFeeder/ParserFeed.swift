//
//  Parser.swift
//  RSSFeed
//
//  Created by Антон Рыскалев on 11.02.17.
//
//

import UIKit
import CoreData
import FeedKit

public struct FeedItem {
    let title: String
    let description: String
    let pubDate: Date
    let image: UIImage?
    let url: URL
    let favorite: Bool
    let feedName: String
}

class ParserFeed: NSObject {
    
    private var feedModel : FeedsModel? = FeedsModel()
    
    var feedArray: [FeedItem] = [] {
        didSet {
            feedArray = feedArray.sorted(by: {$0.pubDate.compare($1.pubDate) == .orderedDescending})
        }
    }

    open func parse(completionHandler: @escaping (Bool)->()) {
        
        guard feedModel != nil else {
            completionHandler(false)
            return
        }
        
        let feeds = feedModel?.getFeedList()
        feedArray.removeAll()
        
        if feeds?.count != 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                for feedData in feeds! {
                    if let url = URL(string: feedData.url!) {
                        
                        if let data = NSData(contentsOf: url) as? Data {
                        
                            FeedParser(data: data).parse({ (result) in
                            
                            guard let feed = result.rssFeed, result.isSuccess else {
                                print(result.error)
                                completionHandler(false)
                                return
                            }
                            
                            var image = UIImage(named: "nophoto")
                            
                            if let imageURL = feed.image?.url {
                                if let imageData = try? Data(contentsOf: URL(string: imageURL)!) {
                                    image = UIImage(data: imageData)
                                }
                            }
                            
                            if let items = feed.items {
                                for item in items {
                                    if let title = item.title, let description = item.description, let pubDate = item.pubDate, let url = URL(string: item.link!) {
                                        self.feedArray.append(FeedItem(title: title, description: description, pubDate: pubDate, image: image, url: url, favorite: feedData.favorite, feedName: feedData.name!))
                                    }
                                    
                                }
                            }
                            
                        })
                        } else {
                            print("Can't parse data \(feedData.name)")
                        }
                    }
                    if self.feedArray.count != 0 {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
        
        
        
    }
    
    
    
}
