//
//  HomeViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/4/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UICollectionViewController, HomeHeadlineDelegates
{
    var headlineSection : [HeadlineInfo]? = []
    var dataSections : Array<Array<Any>>? = []
    var currentSection : Int = 0
    var headerViewNib : UINib!
    var menuList : MainMenuListViewController?
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        headerViewNib = UINib.init(nibName: "HomeHeader", bundle: nil)
        if let homePage = TestDataManager.sharedManager.homePage {
            let announceArray = homePage["Announcements"] as? [AnyObject]
            let activityArray = homePage["SchoolActivities"] as? [AnyObject]
            let reportArray = homePage["SchoolReports"] as? [AnyObject]
            dataSections = [announceArray!, activityArray!, reportArray!]
            
            if let headlines = homePage["HeaderNews"] as? [[String:String]] {
                for headline  in headlines {
                    let headlineObj = HeadlineInfo()
                    headlineObj.title = headline["Title"]
                    headlineObj.message = headline["Message"]
                    headlineObj.msgDetail = headline["MessageDetail"]
                    headlineObj.url = headline["FollowUrl"]
                    if let imageName = headline["Image"] {
                        headlineObj.image = UIImage.init(named: imageName)
                    }
                    headlineSection?.append(headlineObj)
                }
            }
        }
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.register(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "header")
//        self.preferredStatusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        reloadLayout()
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        reloadLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    func reloadLayout()
    {
        if let layout = collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: 404)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: self.view.frame.size.width, height: 80);
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: layout.itemSize.height);
            layout.parallaxHeaderAlwaysOnTop = true;
            
            // If we want to disable the sticky header effect
            layout.disableStickyHeaders = true;
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Only display one section at a time.
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.dataSections?[currentSection].count {
            return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        let sectionArray = dataSections?[currentSection] as? Array<Dictionary<String, String>>
        let item = sectionArray?[indexPath.row]
        cell.date.text = item?["Date"]
        cell.title.text = item?["Title"]
        cell.detail.text = item?["Detail"]
        if let imageName = item?["image"]{
            cell.image.image = UIImage.init(named: imageName)
        }
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == CSStickyHeaderParallaxHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HomeHeader
            view.delegateView = self
            if(self.headlineSection != nil){
                view.headlineInfos = self.headlineSection!
            }
            return view
        }
//        if kind == UICollectionElementKindSectionHeader {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! HomeSectionHeader
        view.noticeButton.setTitle("通知", for: UIControlState.normal)
        view.activityButton.setTitle("活动", for: UIControlState.normal)
        view.reportButton.setTitle("报表", for: UIControlState.normal)
        view.noticeButtonPressed(self)
        return view
    }
    func headlineMenuButtonSelected(_ headline : HeadlineInfo?) {
        if self.menuList == nil {
            self.menuList = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainMenuList") as? MainMenuListViewController
        }
        #if USE_POPOVER
        self.menuList?.modalPresentationStyle = .popover
        self.menuList?.preferredContentSize = CGSize(width: 200, height: 500)
        self.present(self.menuList!, animated: true, completion: nil)
        self.menuList?.popoverPresentationController?.sourceView = self.view
        self.menuList?.popoverPresentationController?.sourceRect = CGRect(x: 50, y: 50, width: 0, height: 0)
        #else
            self.slideInTransitioningDelegate.direction = .left
            self.slideInTransitioningDelegate.disableCompactHeight = false
            self.slideInTransitioningDelegate.presentedViewEdgeInset = UIEdgeInsets.init(top: 80, left: 0, bottom: 60, right: 0)
            self.menuList?.transitioningDelegate = self.slideInTransitioningDelegate
            self.menuList?.modalPresentationStyle = .custom
            self.present(self.menuList!, animated: true, completion: nil)
        #endif

    }
    func headlineInfoButtonSelected(_ headline : HeadlineInfo?) {
        // Do nothing
    }
    func headlineFollowButtonSelected(_ headline : HeadlineInfo?) {
        if let urlString = headline?.url {
            let url = URL.init(string: urlString)
            UIApplication.shared.openURL(url!)
        }
    }
}

class HomeSectionHeader : UICollectionReusableView
{
    @IBOutlet weak var noticeButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBAction func noticeButtonPressed(_ sender: Any) {
        noticeButton.backgroundColor = UIColor.init(hexString:"#2B75A2")
        activityButton.backgroundColor = UIColor.init(hexString: "#4396C9")
        reportButton.backgroundColor = UIColor.init(hexString: "#4396C9")
    }
    @IBAction func activityButtonPressed(_ sender: Any) {
        noticeButton.backgroundColor = UIColor.init(hexString: "#4396C9")
        activityButton.backgroundColor = UIColor.init(hexString:"#2B75A2")
        reportButton.backgroundColor = UIColor.init(hexString: "#4396C9")
    }
    @IBAction func reportButtonPressed(_ sender: Any) {
        noticeButton.backgroundColor = UIColor.init(hexString: "#4396C9")
        activityButton.backgroundColor = UIColor.init(hexString: "#4396C9")
        reportButton.backgroundColor = UIColor.init(hexString:"#2B75A2")
    }
    
}

class HomeCollectionViewCell : UICollectionViewCell
{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var divider: UIImageView!
    
}

