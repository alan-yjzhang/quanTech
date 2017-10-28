//
//  MainMenuListViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/6/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class menuListPersonCell : UITableViewCell
{
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var systemNo: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var region: UILabel!
}

class MainMenuListViewController : UITableViewController
{
    var menuList : [[String:String]]? = nil
    var person : Person? = nil
    
//    override func viewWillLayoutSubviews() {
//        var frame = self.view.frame
//        frame.size = CGSize.init(width: 200, height: frame.height)
//        self.view.frame = frame
//        super.viewWillLayoutSubviews()
//    }
    override func viewDidLoad() {
        self.menuList = TestDataManager.sharedManager.menuList as? [[String:String]]
        self.person = TestDataManager.sharedManager.person
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
//        let newFrame = CGRect(x: 0, y: 50, width: 200, height: self.view.frame.height-50)
//        self.view.frame = CGRect(x: 0, y: 50, width: 0, height: self.view.frame.height-50)
//        UIView.animate(withDuration: 0.5) {
//            self.view.frame = newFrame
//        }
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if person != nil {
            return 2
        }
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if person != nil {
            if section == 0 {
                return 1
            }
        }
        if let count = self.menuList?.count {
            return count
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 160
        }
        return 40
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if person != nil {
            if indexPath.section == 0 {
                let personCell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath) as! menuListPersonCell
                personCell.name.text =  person?.fullName
                personCell.systemNo.text = person?.systemId
                personCell.className.text = person?.classRoom
                personCell.school.text = person?.school
                personCell.region.text = person?.region
                personCell.profession.text = person?.profession
                personCell.personImage.image = person?.personIcon
                return personCell
            }
        }
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "submenuCell", for: indexPath)
        let menu = self.menuList?[indexPath.row]
        menuCell.textLabel?.text = menu?["Title"]
        if let imageName = menu?["image"] {
            menuCell.imageView?.image = UIImage.init(named: imageName)
        }
        return menuCell
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let menu = self.menuList?[indexPath.row]
        if let linkUrl = menu?["link"] {
            if linkUrl.isEmpty == false{
                UIApplication.shared.openURL(URL.init(string: linkUrl)!)
            }
        }
    }
}
