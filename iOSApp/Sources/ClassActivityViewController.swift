//
//  ClassActivityViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 2/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//
import Foundation
import UIKit
class ClassActivityViewController: LoadableCollectionViewController, UICollectionViewDelegateFlowLayout
{
    var classActivities : [[String:String]]? = nil
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
//        self.classActivities = TestDataManager.sharedManager.classActivities as? [[String:String]]
        self.person = TestDataManager.sharedManager.person
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize.init(width: 100, height: 100)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.classActivities?.count {
            return count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "classActivitiesCell", for: indexPath) as! ScoreListCell
        let score = self.classActivities?[indexPath.row]
        
        scoreCell.courseName.text = score?["Title"]
        scoreCell.date.text = score?["Date"]
        scoreCell.scoreDetail.text = score?["Detail"]
        scoreCell.typeName.text = score?["Type"]
        if let imageName = score?["image"] {
            scoreCell.courseImage.image = UIImage.init(named: imageName)
        }
        return scoreCell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "classActivitiesHeader", for: indexPath) as! ScoreListHeader
            headerView.personDetail.text = person?.selfDescription
            headerView.personName.text = person?.fullName
            headerView.personImage.image = person?.personIcon
            headerView.backgroundColor = UIColor.gray
            return headerView
            
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
}

