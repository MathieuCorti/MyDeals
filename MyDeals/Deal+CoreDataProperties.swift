//
//  Deal+CoreDataProperties.swift
//  MyDeals
//
//  Created by Mathieu Corti on 9/6/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import Foundation
import CoreData


extension Deal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Deal> {
        return NSFetchRequest<Deal>(entityName: "Deal")
    }

    @NSManaged public var desc: String?
    @NSManaged public var imageLink: String?
    @NSManaged public var link: String?
    @NSManaged public var merchant: String?
    @NSManaged public var price: String?
    @NSManaged public var title: String?
    @NSManaged public var isEditable: Bool
    @NSManaged public var image: NSData?
    @NSManaged public var imageSrc: Int16

    
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "Deal", in: context!)
        
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }

}
