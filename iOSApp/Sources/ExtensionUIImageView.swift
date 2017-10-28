//
//  ExtensionUIImageView.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
extension UIImageView
{
    func applyShadow(){
        let layer           = self.layer
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius  = 2
    }
}
