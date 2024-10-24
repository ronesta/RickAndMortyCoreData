//
//  CoreDataManager.swift
//  RickAndMortyCoreData
//
//  Created by Ибрагим Габибли on 24.10.2024.
//

import Foundation
import UIKit
import CoreData

// MARK: - CRUD
public final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}

    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }

    public func createCharacter(gender: String, image: String, location: String, name: String, species: String, status: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Entity", in: context) else {
            return
        }

        let entity = Entity(entity: entityDescription, insertInto: context)
        entity.gender = gender
        entity.image = image
        entity.location = location
        entity.name = name
        entity.species = species
        entity.status = status

        appDelegate.saveContext()
    }

    public func fetchCharacters() -> [Entity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

        do {
            return try context.fetch(fetchRequest) as! [Entity]
        } catch {
            print(error.localizedDescription)
        }

        return []
    }

    public func fetchCharacter(image: String) -> Entity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "image == %@", image)

        do {
            let entities = try? context.fetch(fetchRequest) as? [Entity]
            return entities?.first
        }
    }

    public func updateCharacter(with image: String, newImage: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "image == %@", image)

        do {
            guard let entities = try? context.fetch(fetchRequest) as? [Entity],
            let entity = entities.first else {
                return
            }
            entity.image = newImage
        }

        appDelegate.saveContext()
    }

    public func deleteAllCharacters() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

        do {
            let entities = try? context.fetch(fetchRequest) as? [Entity]
            entities?.forEach { context.delete($0) }
        }

        appDelegate.saveContext()
    }

    public func deleteCharacter(with image: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "image == %@", image)

        do {
            guard let entities = try? context.fetch(fetchRequest) as? [Entity],
                  let entity = entities.first else {
                return
            }
            context.delete(entity)
        }

        appDelegate.saveContext()
    }
}
