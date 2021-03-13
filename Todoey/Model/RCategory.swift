//
//  Category.swift
//  Todoey
//
//  Created by Alexandra Negru on 22/02/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RCategory: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item> ()
}
