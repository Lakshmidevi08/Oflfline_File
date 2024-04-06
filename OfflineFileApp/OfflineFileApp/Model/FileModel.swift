//
//  FileModel.swift
//  OfflineFileApp
//
//  Created by VC on 03/04/24.
//

import Foundation
import UIKit

class File {
    var name: String
    var type: String
    var imageData: Data
    var path: String
    var folderName: String
    
    init(name: String, type: String,imageData:Data, path: String, folderName:String) {
        self.name = name
        self.type = type
        self.path = path
        self.imageData = imageData
        self.folderName = folderName
    }
}
