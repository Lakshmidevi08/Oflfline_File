//
//  FolderModel.swift
//  OfflineFileApp
//
//  Created by VC on 02/04/24.
//

import Foundation
import UIKit


class Folder {
    var name: String
    var creationDate: String
    var color: String
    var isFavorite: Bool
    
    init(name: String, creationDate: String, color: String, isFavorite: Bool) {
        self.name = name
        self.creationDate = creationDate
        self.color = color
        self.isFavorite = isFavorite
        
    }
}
