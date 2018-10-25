//
//  FileViewController.swift
//  CloudServices
//
//  Created by для интернета on 25.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {
    
    var file: FilesTree?
    
    var backgroundColor: UIColor
    
    // Selected file name
    let fileName = UILabel()
    
    // File preview
    let preview = UIImageView()
    
    // Selected file size/modified
    let fileAttributes = UILabel()
    
    // Selected file URL
    let fileURL = UILabel()
    
    convenience init(backgroundColor: UIColor) {
        self.init(nibName: nil, bundle: nil)
        
        self.backgroundColor = backgroundColor
    }
    
    convenience init(backgroundColor: UIColor, file: FilesTree) {
        self.init(nibName: nil, bundle: nil)
        
        self.backgroundColor = backgroundColor
        self.file = file
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        backgroundColor = .white
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = backgroundColor
        
        // Selected file name
        fileName.textAlignment = .center
        
        view.addSubview(fileName)
        ViewController.performAutolayoutConstants(subview: fileName, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - 150, bottom: -(view.frame.height / 2 + 150 - 30))
        
        // Selected file preview
        
        view.addSubview(preview)
        ViewController.performAutolayoutConstants(subview: preview, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - 100, bottom: -(view.frame.height / 2 + 100 - view.frame.width))
        
        // Selected file size/modified
        fileAttributes.textAlignment = .center
        fileAttributes.textColor = .gray
        
        view.addSubview(fileAttributes)
        ViewController.performAutolayoutConstants(subview: fileAttributes, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 + 220, bottom: -(view.frame.height / 2 - 220 - 30))
        
        // Selected file URL
        fileURL.textAlignment = .center
        fileURL.textColor = .gray
        
        view.addSubview(fileURL)
        ViewController.performAutolayoutConstants(subview: fileURL, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 + 240, bottom: -(view.frame.height / 2 - 240 - 30))
        
        appendUI()
    }
    
    func appendUI() {
        if file == nil {
            fileName.text = "No file selected"
            preview.image = UIImage(named: "dummyFile.png")
            fileAttributes.text = ""
            fileURL.text = ""
        } else {
            fileName.text = file?.name
            if let previewImage = file?.preview {
                preview.image = previewImage
            } else {
                preview.image = UIImage(named: "dummyFile.png")
            }
            fileAttributes.text = FilesDelegateDataSource.attributesString(fileName: file!)
            fileURL.text = file?.urlString ?? ""
        }
    }
}
