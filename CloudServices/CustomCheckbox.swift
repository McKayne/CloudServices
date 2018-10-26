//
//  CustomCheckbox.swift
//  CloudServices
//
//  Created by для интернета on 25.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class CustomCheckbox: UIView {
    
    var isChecked: Bool = false
    let imageView: UIImageView
    let tapRecognizer: UITapGestureRecognizer
    let filesListDataSource: FilesDelegateDataSource?
    let searchListDataSource: SearchDelegateDataSource?
    
    init(frame: CGRect, filesListDataSource: FilesDelegateDataSource) {
        imageView = UIImageView(frame: frame)
        tapRecognizer = UITapGestureRecognizer()
        self.filesListDataSource = filesListDataSource
        self.searchListDataSource = nil
        super.init(frame: frame)
        
        addSubview(imageView)
        
        tapRecognizer.addTarget(self, action: #selector(checkboxAction(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    init(frame: CGRect, searchListDataSource: SearchDelegateDataSource) {
        imageView = UIImageView(frame: frame)
        tapRecognizer = UITapGestureRecognizer()
        self.filesListDataSource = nil
        self.searchListDataSource = searchListDataSource
        super.init(frame: frame)
        
        addSubview(imageView)
        
        tapRecognizer.addTarget(self, action: #selector(checkboxAction(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(frame: .zero)
        tapRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        filesListDataSource = nil
        searchListDataSource = nil
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        if isChecked {
            imageView.image = UIImage(named: "checked.png")
        } else {
            imageView.image = UIImage(named: "unchecked.png")
        }
        imageView.setNeedsDisplay()
        
        var selectedCount = 0
        if let filesList = filesListDataSource {
            for nth in filesList.selectionCheckbox {
                if nth.isChecked {
                    selectedCount += 1
                }
            }
        } else {
            for nth in (searchListDataSource?.selectionCheckbox)! {
                if nth.isChecked {
                    selectedCount += 1
                }
            }
        }
        print(selectedCount)
        
        if selectedCount > 0 {
            if let filesList = filesListDataSource {
                filesList.filesListController.attachButton.setTitle("Attach \(selectedCount)", for: .normal)
                filesList.filesListController.attachButton.isHidden = false
            } else {
                searchListDataSource?.searchController.attachButton.setTitle("Attach \(selectedCount)", for: .normal)
                searchListDataSource?.searchController.attachButton.isHidden = false
            }
        } else {
            if let filesList = filesListDataSource {
                filesList.filesListController.attachButton.isHidden = true
            } else {
                searchListDataSource?.searchController.attachButton.isHidden = true
            }
        }
    }
    
    func checkboxAction(recognizer: UITapGestureRecognizer) {
        print("TAPPED")
        isChecked = !isChecked
        setNeedsDisplay()
    }
}
