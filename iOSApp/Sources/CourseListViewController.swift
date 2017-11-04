//
//  CourseListViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 2/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyXMLParser
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
    var courseList1 : [[String:String]]? = nil
    var courseList : [Course]?
    var person : Person? = nil
    var selectedCourse : Int = 0
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
        #if TEST
        self.courseList = TestDataManager.sharedManager.courseList as? [[String:String]]
        person = TestDataManager.sharedManager.person
        #else
            person = SMSAPI.userProfile
        #endif
        super.viewDidLoad()
    }

    func loadCourseList() {
        guard SMSAPI.isLoggedIn() == true else {
            let alert = UIAlertController(title: "系统错误", message: "请先登录", preferredStyle: .alert)
            let OKAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
            })
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        SMSAPITeacher.sharedSMSTeacherAPI.getClassList { (xmlResponse , error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let alert = UIAlertController(title: "系统错误", message: "无法获取课程表！", preferredStyle: .alert)
                    let OKAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                    })
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.courseList = [Course]()
                let courseList = xmlResponse as! XML.Accessor
                var courseIndex = 0
                for courseXML in courseList["CLASS"] {
                    //{"Title": "语文", "Date" : "12/1/2016", "Detail" : "", "image":"course_1"},
                    let course = Course()
                    course.title = courseXML["VCCOURSENAME"].text
                    course.shortTitle = courseXML["VCSHORTNAME"].text
                    course.iconName = Course.courseIconList[courseIndex]
                    course.courseId = courseXML["VCCOURSEID"].text
                    course.section = courseXML["VCSECTION"].text
                    course.scheduleId = courseXML["ISCHEDULEID"].text
                    course.schoolCode = courseXML["ISCHOOLCODE"].text
                    course.teacherId = courseXML["ITEACHERID"].text
                    course.teacherName = courseXML["VCTEACHERNAME"].text
                    course.schoolName = courseXML["VCSCHOOLNAME"].text
                    course.homeRoom = courseXML["VCHOMEROOM"].text
                    course.credits = Int( Float(courseXML["VCCREDITS"].text ??  "0")! )
                    course.studentNum = Int(Float(courseXML["INUMSTUDENTS"].text ?? "0")!)
                    courseIndex = courseIndex + 1
                    self.courseList?.append(course);
                }
                self.collectionView?.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString:"#4396C9")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "课程动态", style: .plain, target: nil, action: nil)
        
        super.viewWillAppear(animated)
        self.loadCourseList()
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
        
        courseCell.courseName.text = course?.title
        if let imageName = course?.iconName {
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
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCourse = indexPath.item
        self.performSegue(withIdentifier: "listStudents", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listStudents" {
            let vc = segue.destination as! CourseStudentListViewController
            vc.courseInfo = self.courseList?[self.selectedCourse]
        }
    }
}

