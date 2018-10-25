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
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        tapRecognizer = UITapGestureRecognizer()
        super.init(frame: frame)
        
        addSubview(imageView)
        
        tapRecognizer.addTarget(self, action: #selector(checkboxAction(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(frame: .zero)
        tapRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        if isChecked {
            imageView.image = UIImage(named: "checked.png")
        } else {
            imageView.image = UIImage(named: "unchecked.png")
        }
        imageView.setNeedsDisplay()
    }
    
    func checkboxAction(recognizer: UITapGestureRecognizer) {
        print("TAPPED")
        isChecked = !isChecked
        setNeedsDisplay()
    }
}
