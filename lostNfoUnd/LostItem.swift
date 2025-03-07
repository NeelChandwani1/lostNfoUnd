//
//  LostItem.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 3/4/25.
//

import Foundation

struct LostItem: Identifiable {
    let id: String // Firestore document ID
    let name: String
    let description: String
    let location: String
    var status: String = "lost" // "lost" or "found"
    let reportedBy: String // User ID of the user who reported the item
}
