//
//  Entity+CoreDataProperties.swift
//  RickAndMortyCoreData
//
//  Created by Ибрагим Габибли on 24.10.2024.
//
//

import Foundation
import CoreData

@objc(Entity)
public class Entity: NSManagedObject {
}

extension Entity {
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
//        return NSFetchRequest<Entity>(entityName: "Entity")
//    }

    @NSManaged public var gender: String?
    @NSManaged public var image: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var species: String?
    @NSManaged public var status: String?

}

extension Entity: Identifiable {
}
