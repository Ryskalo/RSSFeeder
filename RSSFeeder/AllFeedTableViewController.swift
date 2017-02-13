//
//  AllFeedTableViewController.swift
//  RSSFeeder
//
//  Created by Антон Рыскалев on 12.02.17.
//  Copyright © 2017 Антон Рыскалев. All rights reserved.
//

import UIKit
import SafariServices

class AllFeedTableViewController: UITableViewController {
    
    private var parser: ParserFeed?
    private var posts: [FeedItem] = [] {
        didSet {
            
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        parser = ParserFeed()
        update()
    
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(update), for: UIControlEvents.valueChanged)
        
    }
    
    @objc private func update() {
        
        parser?.parse(completionHandler: { (success) in
            if success {
                self.posts = (self.parser?.feedArray)!
            } else {
                self.showSimpleAlert(message: "Can't get your Feed. Try again later")
            }
        })
        refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell {
            let post = self.posts[indexPath.section]
            
            cell.titleLabel.text = post.title
            cell.descriptionLabel.text = post.description
            cell.imagePost.image = post.image
            cell.pubDateLabel.text = post.pubDate.toString(format: "HH:mm")
            
            return cell
        } else {
            return PostTableViewCell(style: .default, reuseIdentifier: "PostCell")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return posts[section].feedName
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(url: posts[indexPath.row].url)
            present(safariVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(posts[indexPath.row].url)
        }
            self.navigationController?.present(FeedsTableViewController(), animated: true, completion: nil)
    }
    
    private func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: "Something Went Wrong", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
