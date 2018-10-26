//
//  DropboxFile.swift
//  CloudServices
//
//  Created by Nikolay Taran on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class DropboxFile: NSObject {
    
    var preview: UIImageView?, name: String, attributes: String
    
    init(name: String) {
        preview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        preview?.image = UIImage(named: "dummyFile.jpg")
        
        self.name = name
        self.attributes = ""
    }
}
