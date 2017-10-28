//
//  ScoreListViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/12/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
class ScoreListCell : UICollectionViewCell
{
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var scoreDetail: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var courseImage: UIImageView!
    
    @IBOutlet weak var button: UIButton!
}
class ScoreListHeader : UICollectionReusableView
{
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personDetail: UILabel!
    @IBOutlet weak var personName: UILabel!
}

class ScoreListViewController: LoadableCollectionViewController, UICollectionViewDelegateFlowLayout
{
    var scoreList : [[String:String]]? = nil
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
        self.scoreList = TestDataManager.sharedManager.scoreList as? [[String:String]]
        self.person = TestDataManager.sharedManager.person
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString:"#4396C9")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "成绩列表", style: .plain, target: nil, action: nil)
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize.init(width: collectionView.bounds.size.width, height: 60)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.scoreList?.count {
            return count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "scoreListCell", for: indexPath) as! ScoreListCell
        let score = self.scoreList?[indexPath.row]
        
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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "scoreListHeader", for: indexPath) as! ScoreListHeader
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

