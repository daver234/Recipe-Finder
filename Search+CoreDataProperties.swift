//
//  Search+CoreDataProperties.swift
//  
//
//  Created by David Rothschild on 11/20/17.
//
//

import Foundation
import CoreData


extension Search {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Search> {
        return NSFetchRequest<Search>(entityName: "Search")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var searchTerms: String?

}
