//
//  CoreDataManager.swift
//  RickAndMortyCoreData
//
//  Created by Ибрагим Габибли on 24.10.2024.
//
import Foundation
import UIKit
import CoreData

public final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    // swiftlint:disable:next function_parameter_count
    public func createOrUpdateCharacter(id: Int64,
                                        gender: String,
                                        image: String,
                                        location: String,
                                        name: String,
                                        species: String,
                                        status: String) {
        let fetchRequest = NSFetchRequest<Entity>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let entities = try context.fetch(fetchRequest)
            let entity: Entity
            if let existingEntity = entities.first {
                entity = existingEntity
            } else {
                entity = Entity(context: context)
                entity.id = id
            }

            entity.gender = gender
            entity.image = image
            entity.location = location
            entity.name = name
            entity.species = species
            entity.status = status

            saveContext()
        } catch {
            print("Error fetching entity with id \(id): \(error)")
        }
    }

    func saveCharacters(_ characters: [Character]) {
        for character in characters {
            createOrUpdateCharacter(
                id: Int64(character.id),
                gender: character.gender,
                image: character.image,
                location: character.location.name,
                name: character.name,
                species: character.species,
                status: character.status
            )
        }
    }

    public func fetchCharacters() -> [Entity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

        do {
            return try context.fetch(fetchRequest) as? [Entity] ?? []
        } catch {
            print(error.localizedDescription)
        }
        return []
    }

    public func fetchCharacter(id: Int) -> Entity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let entities = try? context.fetch(fetchRequest) as? [Entity]
            return entities?.first
        }
    }

    public func deleteAllCharacters() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

        do {
            let entities = try? context.fetch(fetchRequest) as? [Entity]
            entities?.forEach { context.delete($0) }
        }
        saveContext()
    }

    public func deleteCharacter(with id: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            guard let entities = try? context.fetch(fetchRequest) as? [Entity],
                  let entity = entities.first else {
                return
            }
            context.delete(entity)
        }
        saveContext()
    }
}
