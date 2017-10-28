//
//  ExtensionUIButton.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
extension UIButton
{
    
    func imageOnRightOfText() {
        self.transform = CGAffineTransform.init(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform.init(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform.init(scaleX: -1.0, y: 1.0)
    }
    func removeAllTargets (){
        for target in self.allTargets {
            self.removeTarget(target, action: nil, for: .allEvents)
        }
    }
}
