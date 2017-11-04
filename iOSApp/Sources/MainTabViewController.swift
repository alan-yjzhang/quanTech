//
//  MainTabViewController.swift
//  quanTech
//
//  Created by Alan Zhang on 10/30/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
class MainTabViewController: UITabBarController {
    func displayLogin() {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
}
