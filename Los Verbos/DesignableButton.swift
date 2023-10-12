//
//  DesignableButton.swift
//  Concurso español
//
//  Created by Scott on 03/08/2017.
//  Copyright © 2017 Scott Brady. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton:  BounceButton {
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var buttonExclusiveTouch: Bool = true {
        didSet {
            self.isExclusiveTouch = buttonExclusiveTouch
        }
    }
}
