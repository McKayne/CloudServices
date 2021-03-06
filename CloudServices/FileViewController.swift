//
//  FileViewController.swift
//  CloudServices
//
//  Created by Nikolay Taran on 25.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {
    
    var file: FilesTree?
    
    var backgroundColor: UIColor
    
    // Имя выбранного файла
    let fileName = UILabel()
    
    // Превью
    let preview = UIImageView()
    
    // Строка аттрибутов
    let fileAttributes = UILabel()
    
    // URL файла в Dropbox
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
        
        // Имя выбранного файла
        fileName.textAlignment = .center
        fileName.numberOfLines = 0
        view.addSubview(fileName)
        ViewController.performAutolayoutConstants(subview: fileName, view: view, left: 0.0, right: 0.0, top: 0, bottom: -(view.frame.height / 2 + 2 * view.frame.height / 2 / 3))
        
        // URL файла в Dropbox
        fileURL.textAlignment = .center
        fileURL.numberOfLines = 0
        fileURL.textColor = .lightGray
        
        view.addSubview(fileURL)
        ViewController.performAutolayoutConstants(subview: fileURL, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - 2 * view.frame.height / 2 / 3, bottom: -(view.frame.height / 2 + view.frame.height / 2 / 3))
        
        // Строка аттрибутов
        fileAttributes.textAlignment = .center
        fileAttributes.numberOfLines = 0
        fileAttributes.textColor = .lightGray
        
        view.addSubview(fileAttributes)
        ViewController.performAutolayoutConstants(subview: fileAttributes, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - view.frame.height / 2 / 3, bottom: -view.frame.height / 2)
        
        // Превью
        view.addSubview(preview)
        ViewController.performAutolayoutConstants(subview: preview, view: view, left: 15.0, right: -15.0, top: view.frame.height / 2 + 15, bottom: -15)
        
        appendUI()
    }
    
    // Вызывается при обновлении информации о текущем файле
    func appendUI() {
        if file == nil {
            fileName.text = "No file selected"
            preview.image = UIImage(named: "dummyFile.jpg")
            fileAttributes.text = ""
            fileURL.text = ""
        } else {
            fileName.text = file?.name
            if let previewImage = file?.preview {
                preview.image = previewImage
            } else {
                preview.image = UIImage(named: "dummyFile.jpg")
            }
            fileAttributes.text = FilesDelegateDataSource.attributesString(fileName: file!)
            fileURL.text = file?.urlString ?? ""
        }
        fileName.sizeToFit()
        fileURL.sizeToFit()
        fileAttributes.sizeToFit()
    }
}
