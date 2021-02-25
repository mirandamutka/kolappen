//
//  Shop.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-10.
//

import Foundation
import FirebaseFirestoreSwift

struct Shop : Codable, Identifiable {
    @DocumentID var id : String?
    var shopName : String
//    var hoursOpen : [String]
//    var hoursClosed : [String]
    var shopOpen : Bool
    var currentQueueNumber : Int
    var highestQueueNumber : Int
    var uid : String
}
