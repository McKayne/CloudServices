//
//  FilesTree.swift
//  CloudServices
//
//  Created by Nikolay Taran on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

// Файлы и папки в приложении хранятся в виде дерева.
class FilesTree: NSObject {
    
    let isDirectory: Bool
    var name: String
    var size: Int?
    var dateString: String?
    var urlString: String?
    var preview: UIImage?
    var childFiles: [FilesTree] = []
    var file: DropboxFile?
    
    
    init(isDirectory: Bool, name: String) {
        self.isDirectory = isDirectory
        self.name = name
    }
}
