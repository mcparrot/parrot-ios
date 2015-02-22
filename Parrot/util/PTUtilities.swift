//
//  PTUtilities.swift
//  Parrot
//
//  Created by Jack Cook on 2/21/15.
//  Copyright (c) 2015 Jack Cook. All rights reserved.
//

import UIKit

class PTSlider: UISlider {
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(0, 0, bounds.width, 15.5)
    }
}
