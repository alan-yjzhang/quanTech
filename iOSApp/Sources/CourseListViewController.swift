//
//  CourseListViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 2/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class CourseListCell : UICollectionViewCell
{
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseImage: UIImageView!
}
class CourseListHeader : UICollectionReusableView
{
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personDetail: UILabel!
    @IBOutlet weak var personName: UILabel!
}

class CourseListViewController: LoadableCollectionViewController, UICollectionViewDelegateFlowLayout
{
    var courseList : [[String:String]]? = nil
    var person : Person? = nil
    override func viewDidLoad() {
//        self.loggingEnabled = true
//        self.defaultLoadingUrl = "https://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/master/AlamofireJsonToObjectsTests/sample_json"
//        let xmlUrl = "https://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample_xml"
//        self.downloadJSON(url: xmlUrl, shouldSpin: true) {
//            (response) in
//            switch(response.result){
//            case .success(let JSON):
//                print(JSON)
//            case .failure(let error):
//                print(error)
//            }
//        }
        self.courseList = TestDataManager.sharedManager.courseList as? [[String:String]]
        person = TestDataManager.sharedManager.person
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString:"#4396C9")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "课程动态", style: .plain, target: nil, action: nil)
        
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize.init(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.courseList?.count {
            return count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let courseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseListCell", for: indexPath) as! CourseListCell
        let course = self.courseList?[indexPath.row]
        
        courseCell.courseName.text = course?["Title"]
        if let imageName = course?["image"] {
            courseCell.courseImage.image = UIImage.init(named: imageName)
        }
        return courseCell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "courseListHeader", for: indexPath) as! CourseListHeader
            headerView.personDetail.text = person?.selfDescription
            headerView.personName.text = person?.fullName
            headerView.personImage.image = person?.personIcon
//            headerView.backgroundColor = UIColor.gray
            return headerView
            
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
}

