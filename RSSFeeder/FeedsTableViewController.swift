//
//  FeedsTableViewController.swift
//  RSSFeeder
//
//  Created by Антон Рыскалев on 12.02.17.
//  Copyright © 2017 Антон Рыскалев. All rights reserved.
//

import UIKit

class FeedsTableViewController: UITableViewController {
    
    private var feedsModel: FeedsModel?
    private var feeds:[Feed] = [] {
        didSet{
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        feedsModel = FeedsModel()
        
    }
    
    private func update() {
        self.feeds = (feedsModel?.getFeedList())!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as UITableViewCell
        
        let item = self.feeds[indexPath.row]
        
        cell.textLabel?.text = item.favorite ? "\(item.name!) (Favorite)" : item.name
        cell.detailTextLabel?.text = item.url
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            let post = self.feeds[index.row]
            
            self.feedsModel?.deleteFeed(post.name!, url: post.url!, completionHandler: { (success) in
                self.update()
                print(success)
            })
            
        }
        delete.backgroundColor = UIColor.red
        
        let modify = UITableViewRowAction(style: .normal, title: "Edit") { (action, index) in
            let post = self.feeds[index.row]
            self.showAlertWithTextFields(titleOfAlert: "Edit Feed", titleFieldText: post.name, urlFieldText: post.url)
        }
        modify.backgroundColor = UIColor.lightGray
        
        let makeFavorite = UITableViewRowAction(style: .normal, title: "Favorite") { (action, index) in
        let post = self.feeds[index.row]
            self.feedsModel?.markUnmarkFavoriteFeed(post.name!, url: post.url!, completionHandler: { (success) in
                print(success)
                self.update()
                
            })
        }
        makeFavorite.backgroundColor = UIColor.blue
        
        
        return [delete, modify, makeFavorite]
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    private func showAlertWithTextFields(titleOfAlert:String, titleFieldText:String?, urlFieldText:String?) {
        let actionAlert = UIAlertController(title: titleOfAlert, message: nil, preferredStyle: .alert)
        
        actionAlert.addTextField { (textField) in
            if (titleFieldText != nil) {
                textField.text = titleFieldText
            } else {
                textField.placeholder = "Title"
            }
        }
        actionAlert.addTextField { (textField) in
            if (urlFieldText != nil) {
                textField.text = urlFieldText
            } else {
                textField.placeholder = "URL"
            }
        }
        
        actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
            let textFields = actionAlert.textFields
            
            guard let title = textFields?[0].text, title != "", title != " " else {
                self.showSimpleAlert(message: "All fields must be filled")
                return
            }
            guard let url = textFields?[1].text, url != "", url != " " else {
                self.showSimpleAlert(message: "All fields must be filled")
                return
            }
            
            if (titleFieldText != nil) && (urlFieldText != nil) {
               self.feedsModel?.modifyFeedData(titleFieldText!, url: urlFieldText!, newName: title, newUrl: url, completionHandler: { (success) in
                print(success)
                if success {
                    self.update()
                } else {
                    self.showSimpleAlert(message: "Can't edit Feed Data. Try again later.")
                }
               })
                
            } else {
                self.feedsModel?.saveFeed(title, url: url, completionHandler: { (success, message) in
                    print(success)
                    if success {
                        self.update()
                    } else {
                        self.showSimpleAlert(message: "Can't save Feed Data. Try again later.")
                    }
                })
            }
        }))
        
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    private func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: "Something Went Wrong", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addFeedButtonPressed(_ sender: UIBarButtonItem) {
       showAlertWithTextFields(titleOfAlert: "Add Feed", titleFieldText: nil, urlFieldText: nil)
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
