//
//  ClientData+CoreDataProperties.swift
//  
//
//  Created by Idris Mahamdi on 20/04/2022.
//
//

import Foundation
import CoreData


extension ClientData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClientData> {
        return NSFetchRequest<ClientData>(entityName: "ClientData")
    }

    @NSManaged public var gamestarted: Bool
    @NSManaged public var traitor: Bool
    @NSManaged public var tasksCompleted: Bool
    @NSManaged public var gamefinished: Bool
    @NSManaged public var killedPlayer: String
    @NSManaged public var dead: Bool
    @NSManaged public var didcrewwin: Bool
    @NSManaged public var playernumber: String
    @NSManaged public var disconnectdata: Bool



}
