//
//  CourseStudentListViewController.swift
//  quanTech
//
//  Created by Alan Zhang on 11/4/17.
//  Copyright © 2017 AlanZhang. All rights reserved.
//

import Foundation
import SwiftyXMLParser
class CourseStudentListViewController : UITableViewController
{
    var courseInfo : Course?
    var studentList : [Person]?
    
    private let cellIdentifier = "studentCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadStudentList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = courseInfo?.title
    }
    func loadStudentList() {
        guard courseInfo != nil else {
            return
        }
        SMSAPITeacher.sharedSMSTeacherAPI.getStudentList(courseInfo!.courseId!, section: courseInfo!.section!, scheduleId: courseInfo!.scheduleId!) { (xmlResponse, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    let alert = UIAlertController(title: "系统错误", message: "无法获取课程的学生信息 \(self.courseInfo!.title!)", preferredStyle: .alert)
                    let OKAction = UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        // stay until user login
                    })
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.studentList = [Person]()
                let studentListXML = xmlResponse as! XML.Accessor
                for studentXML in studentListXML["STUDENT"] {
                    let student = Person()
                    student.lastName = studentXML["VCASSUMEDLASTNAME",0].text
                    student.firstName = studentXML["VCASSUMEDFIRSTNAME",0].text
                    student.systemId = studentXML["CSTUDENTID"].text
                    self.studentList?.append(student)
                }
                self.tableView.reloadData()
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = studentList?.count {
            return count
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = self.studentList?[indexPath.item].fullName
        cell.detailTextLabel?.text = self.studentList?[indexPath.item].systemId
        return cell
    }
}
