//
//  ScoreListViewController.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/12/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyXMLParser

class GradeBook: NSObject {
    var scheduleId : String?
    var gradeName : String?
    var assignDate : String?
    var dueDate : String?
    var score : String?
    var note: String?
}

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
    var courseList : [Course]?
    var gradeBooks : [String: [GradeBook]]?
    var person : Person? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.person = SMSAPITeacher.userProfile
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(hexString:"#4396C9")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "成绩列表", style: .plain, target: nil, action: nil)
        
        super.viewWillAppear(animated)
        self.loadCourseList()
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
        let course = self.courseList?[section]
        let courseId = course!.courseId
        let gradeBooks = self.gradeBooks?[courseId!]
        if let count = gradeBooks?.count {
            return count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = self.courseList?.count {
            return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "scoreListCell", for: indexPath) as! ScoreListCell
        let course = self.courseList?[indexPath.section]
        let courseId = course!.courseId
        let gradeBooks = self.gradeBooks?[courseId!]
        let grade = gradeBooks![indexPath.item]
        
        scoreCell.courseName.text = course?.title
        scoreCell.date.text = grade.dueDate
        scoreCell.scoreDetail.text = grade.note
        scoreCell.typeName.text = grade.gradeName
        if grade.gradeName?.contains(s: "作业") == true {
            scoreCell.courseImage.image = UIImage.init(named: "icon_scores")
        }else if grade.gradeName?.contains(s: "考试") == true {
            scoreCell.courseImage.image = UIImage.init(named:"icon_polls")
        }else {
            scoreCell.courseImage.image = UIImage.init(named:"icon_scores")
        }
        return scoreCell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "scoreListHeader", for: indexPath) as! ScoreListHeader
            let course = self.courseList?[indexPath.section]
            headerView.personDetail.text = course?.schoolName
            headerView.personName.text = course?.title
            if course?.iconName != nil {
                headerView.personImage.image = UIImage.init(named: course!.iconName!)
            }
            headerView.backgroundColor = UIColor.lightGray
            return headerView
            
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
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
                if self.courseList != nil {
                    for theCourse in self.courseList! {
//                        let refreshView = self.courseList!.last == theCourse
                        self.loadCourseGradeBook(theCourse, refreshView: true)
                    }
                }
            }
        }
    }
    func loadCourseGradeBook(_ course: Course?, refreshView: Bool = true){
        guard course != nil else {
            return
        }
        SMSAPITeacher.sharedSMSTeacherAPI.getHomeworkList(course!.courseId!, section: course!.section!, scheduleId: course!.scheduleId!) { (xmlResponse, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    if refreshView == false {
                        return
                    }
                    let alert = UIAlertController(title: "系统错误", message: "无法获取作业和考试成绩\(course!.title!)!", preferredStyle: .alert)
                    let OKAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                    })
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                var grades = [GradeBook]()
                let gradesXML = xmlResponse as! XML.Accessor
                for gradeXML in gradesXML["GRADEBOOKTASK"] {
                    let grade = GradeBook()
                    grade.scheduleId = gradeXML["ISCHEDULEID"].text
                    grade.gradeName = gradeXML["VCTASKNAME"].text
                    grade.assignDate = gradeXML["DTASSIGNDATE"].text
                    grade.dueDate = gradeXML["DTDUEDATE"].text
                    grade.note = gradeXML["VCNOTES"].text ?? "暂无记录"
                    grade.score = gradeXML["IVALUE"].text ?? "暂无成绩"
                    grades.append(grade)
                }
                if self.gradeBooks == nil {
                    self.gradeBooks = [String:[GradeBook]]()
                }
                self.gradeBooks?[course!.courseId!] = grades
                if refreshView == true {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
}

