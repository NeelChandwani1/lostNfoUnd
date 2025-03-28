//
//  LostItem.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 1/28/25.
//

import Foundation

struct LostItem: Identifiable {
    let id: String 
    let name: String
    let description: String
    let location: String
    var status: String = "lost" 
    let reportedBy: String 
}
