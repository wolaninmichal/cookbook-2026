//
//  HomeModels.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 08/02/2026.
//

import Foundation
import UIKit
import CoreData

final class HomeModels {
    typealias SectionID = String
    typealias ItemID = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>
}
