//
//  MRecipePage+CoreDataProperties.swift
//  
//
//  Created by David Rothschild on 11/24/17.
//
//

import Foundation
import CoreData


extension MRecipePage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MRecipePage> {
        return NSFetchRequest<MRecipePage>(entityName: "MRecipePage")
    }

    @NSManaged public var mCount: Int16
    @NSManaged public var mCreatedAt: NSDate?
    @NSManaged public var mPageNumber: Int16
    @NSManaged public var mSearchTerm: String?
    @NSManaged public var mRecipes: NSSet?

}

// MARK: Generated accessors for mRecipes
extension MRecipePage {

    @objc(addMRecipesObject:)
    @NSManaged public func addToMRecipes(_ value: MRecipeDetail)

    @objc(removeMRecipesObject:)
    @NSManaged public func removeFromMRecipes(_ value: MRecipeDetail)

    @objc(addMRecipes:)
    @NSManaged public func addToMRecipes(_ values: NSSet)

    @objc(removeMRecipes:)
    @NSManaged public func removeFromMRecipes(_ values: NSSet)

}
