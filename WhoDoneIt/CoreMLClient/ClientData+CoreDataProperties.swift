//
//  ClientData+CoreDataProperties.swift
//  WhoDoneIt
//
//  Created by Idris Mahamdi on 13/04/2022.
//
//

import Foundation
import CoreData


extension ClientData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClientData> {
        return NSFetchRequest<ClientData>(entityName: "ClientData")
    }

    @NSManaged public var traitor: Bool
    @NSManaged public var gamestarted: Bool
    @NSManaged public var tasksComplete: Bool

}

extension ClientData : Identifiable {

}
