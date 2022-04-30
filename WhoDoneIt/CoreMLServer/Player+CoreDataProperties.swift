//
//  Player+CoreDataProperties.swift
//
//
//  Created by Idris Mahamdi on 13/04/2022.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var playercount: Int32
    @NSManaged public var gamestarted: Bool
    @NSManaged public var home: Bool

}
