//
//  MRecipeDetail+CoreDataProperties.swift
//  
//
//  Created by David Rothschild on 11/24/17.
//
//

import Foundation
import CoreData


extension MRecipeDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MRecipeDetail> {
        return NSFetchRequest<MRecipeDetail>(entityName: "MRecipeDetail")
    }

    @NSManaged public var mCreatedAt: NSDate?
    @NSManaged public var mImageUrl: String?
    @NSManaged public var mIngredients: [String]?
    @NSManaged public var mPublisher: String?
    @NSManaged public var mPublisherUrl: String?
    @NSManaged public var mRecipeID: String?
    @NSManaged public var mSocialRank: Double
    @NSManaged public var mSourceUrl: String?
    @NSManaged public var mTitle: String?
    @NSManaged public var mUrl: String?
    @NSManaged public var mPage: MRecipePage?

}
