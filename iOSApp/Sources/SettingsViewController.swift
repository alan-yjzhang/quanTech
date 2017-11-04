//
//  SettingsViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 3/9/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController : LoadableDataViewController
{
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var systemNoLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var wechatNo: UITextField!
    @IBOutlet weak var qqNo: UITextField!
    @IBOutlet weak var cellphoneNo: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    var person : Person? = nil
    override open func viewDidLoad() {
//        person = TestDataManager.sharedManager.person
        person = SMSAPI.userProfile
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        nameLabel.text = person?.fullName
        schoolLabel.text = person?.school
        classLabel.text = person?.classRoom
        systemNoLabel.text = person?.systemId
        regionLabel.text = person?.region
        professionLabel.text = person?.profession
        personImage.image = person?.personIcon
        wechatNo.text = person?.wechatNo
        cellphoneNo.text = person?.cellphone
        qqNo.text = person?.qqNo
        emailAddress.text = person?.email

        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString:"#4396C9")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "设置", style: .plain, target: nil, action: nil)

        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard SMSAPI.isLoggedIn() == true else {
            let alert = UIAlertController(title: "系统错误", message: "请先登录", preferredStyle: .alert)
            let OKAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            })
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
}

