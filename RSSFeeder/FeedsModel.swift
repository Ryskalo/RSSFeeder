//
//  FeedsModel.swift
//  RSSFeed
//
//  Created by Антон Рыскалев on 11.02.17.
//
//

import UIKit
import CoreData

class FeedsModel: NSObject {
    
    private var managedObjectContext : NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.databaseContext
    
    private enum CoreDataFields:String {
        case EntityName = "Feed"
        case NameAttributeKey = "name"
        case UrlAttributeKey = "url"
        case FavoriteAttributeKey = "favorite"
    }
    
    open func saveFeed(_ name: String, url: String, completionHandler: (Bool, String)->()) {
        let newRecord = NSEntityDescription.insertNewObject(forEntityName: "Feed", into: managedObjectContext!)
        
        newRecord.setValue(name, forKey: CoreDataFields.NameAttributeKey.rawValue)
        newRecord.setValue(url, forKey: CoreDataFields.UrlAttributeKey.rawValue)
        newRecord.setValue(false, forKey: CoreDataFields.FavoriteAttributeKey.rawValue)
        
        do {
            try managedObjectContext?.save()
            completionHandler(true, "Success")
        } catch {
            completionHandler(false, "Save Error")
            print("NOT SAVED")
        }

    }
    
    open func deleteFeed(_ name: String, url: String, completionHandler: (Bool)->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataFields.EntityName.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            if let fetchResults = try managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    managedObjectContext?.delete(fetchResults.first!)
                    
                    do {
                        try managedObjectContext?.save()
                        completionHandler(true)
                    } catch let error {
                        print(error)
                        completionHandler(false)
                    }
                } else {
                    completionHandler(false)
                }
            }
        } catch let error {
            completionHandler(false)
            print(error)
        }
    }
    
    open func modifyFeedData(_ name: String, url: String, newName: String, newUrl:String, completionHandler: (Bool)->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataFields.EntityName.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@ and url = %@", name, url)
        
        do {
            if let fetchResults = try managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    
                    let managedObjects = fetchResults.first
                    managedObjects?.setValue(newName, forKey: CoreDataFields.NameAttributeKey.rawValue)
                    managedObjects?.setValue(newUrl, forKey: CoreDataFields.UrlAttributeKey.rawValue)
                    
                    do {
                        try managedObjectContext?.save()
                        completionHandler(true)
                    } catch let error {
                        print(error)
                        completionHandler(false)
                    }
                }
            } else {
                completionHandler(false)
            }
        } catch let error {
            print(error)
            completionHandler(false)
        }
    }
    
    open func markUnmarkFavoriteFeed(_ name: String, url: String, completionHandler: (Bool)->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataFields.EntityName.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@ and url = %@", name, url)
        
        do {
            if let fetchResults = try managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    
                    let managedObjects = fetchResults.first
                    if let favorite = managedObjects?.value(forKey: CoreDataFields.FavoriteAttributeKey.rawValue) as? Bool {
                        managedObjects?.setValue(!favorite, forKey: CoreDataFields.FavoriteAttributeKey.rawValue)
                        do {
                            try managedObjectContext?.save()
                            completionHandler(true)
                        } catch let error {
                            print(error)
                            completionHandler(false)
                        }
                    } else {
                        completionHandler(false)
                    }
                }
            } else {
                completionHandler(false)
            }
        } catch let error {
            print(error)
            completionHandler(false)
        }

    }
    
    open func getFeedList() -> [Feed]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.databaseContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataFields.EntityName.rawValue)
        
        
        do {
            let results = try context?.fetch(request) as! [NSManagedObject]
            return results as? [Feed]
        
        } catch  {
            print("error")
            return nil
        }
    }
}
