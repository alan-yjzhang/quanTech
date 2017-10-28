//
//  HomeHeader.swift
//  eduDemo
//
//  Created by Alan Zhang on 12/4/16.
//  Copyright © 2016 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit

class HeadlineInfo {
    var title : String?
    var message : String?
    var image : UIImage?
    var msgDetail: String?
    var info : String?
    var url : String?
}

protocol HomeHeadlineDelegates {
    func headlineMenuButtonSelected(_ headline : HeadlineInfo?) -> Void
    func headlineInfoButtonSelected(_ headline: HeadlineInfo?) -> Void
    func headlineFollowButtonSelected(_ headline: HeadlineInfo?) -> Void
}

class HomeHeader : UICollectionViewCell
{
    @IBOutlet weak var headerBackgroundView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageBackgroundView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var msgDetail: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    var delegateView : HomeHeadlineDelegates?
    
    private var _currentSelectedPage : Int = 0
    private var _headlineInfos : Array<HeadlineInfo> = []
    var headlineInfos : Array<HeadlineInfo> {
        get {
            return _headlineInfos
        }
        set{
            _headlineInfos = newValue
            pageControl.numberOfPages = _headlineInfos.count
            pageControl.currentPage  = 0
            imageView.image = _headlineInfos[pageControl.currentPage].image
            titleLabel.text = _headlineInfos[pageControl.currentPage].title
            message.text = _headlineInfos[pageControl.currentPage].message
            msgDetail.text = _headlineInfos[pageControl.currentPage].msgDetail
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.message.layer.zPosition = 1000
//        self.imageBackgroundView
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        addSwipGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSwipGestures()
    }
    func addSwipGestures(){
        let swipeleft = UISwipeGestureRecognizer.init(target: self, action: #selector(HomeHeader.swipeLeft(_:)))
        swipeleft.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeleft)
        let swiperight = UISwipeGestureRecognizer.init(target: self, action: #selector(HomeHeader.swipeRight(_:)))
        swiperight.direction = UISwipeGestureRecognizerDirection.right
        self.addGestureRecognizer(swiperight)
    }
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer? = nil){
        if( pageControl.currentPage < (pageControl.numberOfPages - 1) ){
            pageControl.currentPage  = pageControl.currentPage + 1
            imageView.image = _headlineInfos[pageControl.currentPage].image
            titleLabel.text = _headlineInfos[pageControl.currentPage].title
            message.text = _headlineInfos[pageControl.currentPage].message
            msgDetail.text = _headlineInfos[pageControl.currentPage].msgDetail
        }
    }
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer? = nil){
        if( pageControl.currentPage > 0){
            pageControl.currentPage  = pageControl.currentPage - 1
            imageView.image = _headlineInfos[pageControl.currentPage].image
            titleLabel.text = _headlineInfos[pageControl.currentPage].title
            message.text = _headlineInfos[pageControl.currentPage].message
            msgDetail.text = _headlineInfos[pageControl.currentPage].msgDetail
        }
    }
    @IBAction func menuButtonPressed(_ sender: Any) {
//        if let vc = delegateView, let method = vc.menuButtonSelected {
            delegateView?.headlineMenuButtonSelected(_headlineInfos[pageControl.currentPage])
//        }
    }
    @IBAction func followButtonPressed(_ sender: Any) {
        delegateView?.headlineFollowButtonSelected(_headlineInfos[pageControl.currentPage])
    }
    @IBAction func infoButtonPressed(_ sender: Any) {
        delegateView?.headlineInfoButtonSelected(_headlineInfos[pageControl.currentPage])
    }
}
